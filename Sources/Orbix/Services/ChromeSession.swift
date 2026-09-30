import CommonCrypto
import Foundation
import Security
import SQLite3

/// Reads the claude.ai `sessionKey` cookie from a Chromium browser (Arc, Chrome, Brave, Edge…),
/// as CodexBar does.
///
/// Chromium on macOS encrypts cookie values with AES-128-CBC. The key is derived (PBKDF2-SHA1,
/// salt `saltysalt`, 1003 rounds) from the browser's "… Safe Storage" Keychain password, so the
/// first read shows a macOS prompt asking to let Orbix use it. Only this one cookie is decrypted.
enum ChromeSession {
    struct Browser: Sendable {
        let name: String
        /// Folder under ~/Library/Application Support that holds the profiles.
        let dataPath: String
        let keychainService: String
        let keychainAccount: String
    }

    static let browsers = [
        Browser(name: "Arc", dataPath: "Arc/User Data", keychainService: "Arc Safe Storage", keychainAccount: "Arc"),
        Browser(name: "Chrome", dataPath: "Google/Chrome", keychainService: "Chrome Safe Storage", keychainAccount: "Chrome"),
        Browser(name: "Brave", dataPath: "BraveSoftware/Brave-Browser", keychainService: "Brave Safe Storage", keychainAccount: "Brave"),
        Browser(name: "Edge", dataPath: "Microsoft Edge", keychainService: "Microsoft Edge Safe Storage", keychainAccount: "Microsoft Edge"),
        Browser(name: "Vivaldi", dataPath: "Vivaldi", keychainService: "Vivaldi Safe Storage", keychainAccount: "Vivaldi"),
        Browser(name: "Chromium", dataPath: "Chromium", keychainService: "Chromium Safe Storage", keychainAccount: "Chromium"),
    ]

    enum ReadError: LocalizedError {
        case chromeNotFound
        case noDiskAccess
        case cannotRead(String)
        case noSession
        case keychainDenied
        case unreadable

        var errorDescription: String? {
            switch self {
            case .chromeNotFound: "No se encontró ningún navegador compatible (Arc, Chrome, Brave, Edge…)."
            case .noDiskAccess: "macOS no deja a Orbix leer las cookies del navegador. Dale «Acceso total al disco» en Ajustes del Sistema → Privacidad y seguridad y vuelve a abrir Orbix."
            case let .cannotRead(reason): "No se pudieron leer las cookies del navegador: \(reason)"
            case .noSession: "No hay sesión de claude.ai en el navegador. Inicia sesión en claude.ai."
            case .keychainDenied: "Sin permiso para la clave del navegador en el Llavero. Pulsa Probar y elige Permitir siempre."
            case .unreadable: "No se pudo descifrar la cookie del navegador."
            }
        }
    }

    /// Derived keys per Keychain service, kept for the app's lifetime so each browser's
    /// Keychain prompt appears at most once per launch.
    nonisolated(unsafe) private static var cachedKeys: [String: Data] = [:]
    private static let lock = NSLock()

    static func sessionKey() throws -> String {
        let databases = cookieDatabases()
        DiagnosticLog.write("browser: \(databases.count) cookie databases")
        guard !databases.isEmpty else { throw ReadError.chromeNotFound }
        var readError: ReadError?
        for (browser, database) in databases {
            let label = "\(browser.name)/\(database.deletingLastPathComponent().lastPathComponent)"
            let row: Row?
            do {
                row = try readRow(from: database)
            } catch let error as CocoaError where error.code == .fileReadNoPermission {
                DiagnosticLog.write("browser: \(label) blocked by macOS privacy")
                readError = .noDiskAccess
                continue
            } catch {
                DiagnosticLog.write("browser: \(label) cannot copy: \(error.localizedDescription)")
                readError = readError ?? .cannotRead(error.localizedDescription)
                continue
            }
            DiagnosticLog.write("browser: \(label) sessionKey \(row.map { "found (schema \($0.schemaVersion))" } ?? "missing")")
            guard let row else { continue }
            if !row.plain.isEmpty { return row.plain }
            return try decrypt(row.encrypted, schemaVersion: row.schemaVersion, browser: browser)
        }
        throw readError ?? .noSession
    }

    /// Every profile of every installed browser, most recently used database first.
    private static func cookieDatabases() -> [(Browser, URL)] {
        let support = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support")
        var found: [(Browser, URL, Date)] = []
        for browser in browsers {
            let root = support.appendingPathComponent(browser.dataPath)
            let names = (try? FileManager.default.contentsOfDirectory(atPath: root.path)) ?? []
            for profile in names where profile == "Default" || profile.hasPrefix("Profile ") {
                for file in ["Network/Cookies", "Cookies"] {
                    let url = root.appendingPathComponent(profile).appendingPathComponent(file)
                    // Metadata is readable even where the contents are privacy-protected.
                    if let modified = try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate {
                        found.append((browser, url, modified))
                    }
                }
            }
        }
        return found.sorted { $0.2 > $1.2 }.map { ($0.0, $0.1) }
    }

    private struct Row {
        let plain: String
        let encrypted: Data
        let schemaVersion: Int
    }

    /// Chrome keeps the database locked while it runs, so read a private copy and delete it.
    /// Bytes are copied by hand into Orbix's own folder: `copyItem` into the system temp
    /// directory fails with a permission error for this file.
    private static func readRow(from database: URL) throws -> Row? {
        let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Orbix", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let copy = folder.appendingPathComponent("cookies-\(UUID().uuidString).sqlite")
        defer { try? FileManager.default.removeItem(at: copy) }
        try Data(contentsOf: database).write(to: copy, options: .atomic)
        try? FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: copy.path)

        var db: OpaquePointer?
        guard sqlite3_open_v2(copy.path, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else {
            DiagnosticLog.write("browser: sqlite open failed")
            sqlite3_close(db)
            return nil
        }
        defer { sqlite3_close(db) }

        var version = 0
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, "SELECT value FROM meta WHERE key = 'version'", -1, &statement, nil) == SQLITE_OK,
           sqlite3_step(statement) == SQLITE_ROW, let text = sqlite3_column_text(statement, 0) {
            version = Int(String(cString: text)) ?? 0
        }
        sqlite3_finalize(statement)

        let query = """
            SELECT value, encrypted_value FROM cookies
            WHERE name = 'sessionKey' AND (host_key = '.claude.ai' OR host_key = 'claude.ai')
            ORDER BY expires_utc DESC LIMIT 1
            """
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else { return nil }
        defer { sqlite3_finalize(statement) }
        guard sqlite3_step(statement) == SQLITE_ROW else { return nil }

        let plain = sqlite3_column_text(statement, 0).map { String(cString: $0) } ?? ""
        let length = Int(sqlite3_column_bytes(statement, 1))
        let encrypted = sqlite3_column_blob(statement, 1).map { Data(bytes: $0, count: length) } ?? Data()
        return Row(plain: plain, encrypted: encrypted, schemaVersion: version)
    }

    static func decrypt(_ value: Data, schemaVersion: Int, browser: Browser = browsers[1],
                        password: Data? = nil) throws -> String {
        guard value.starts(with: Data("v10".utf8)) else { throw ReadError.unreadable }
        let key = try password.map(deriveKey) ?? safeStorageKey(for: browser)
        let iv = Data(repeating: 0x20, count: kCCBlockSizeAES128)
        let ciphertext = value.dropFirst(3)

        var output = Data(count: ciphertext.count + kCCBlockSizeAES128)
        var written = 0
        let status = output.withUnsafeMutableBytes { out in
            ciphertext.withUnsafeBytes { input in
                key.withUnsafeBytes { keyBytes in
                    iv.withUnsafeBytes { ivBytes in
                        CCCrypt(CCOperation(kCCDecrypt), CCAlgorithm(kCCAlgorithmAES), CCOptions(kCCOptionPKCS7Padding),
                                keyBytes.baseAddress, key.count, ivBytes.baseAddress,
                                input.baseAddress, ciphertext.count, out.baseAddress, out.count, &written)
                    }
                }
            }
        }
        guard status == kCCSuccess else { throw ReadError.unreadable }
        var plain = output.prefix(written)
        // Since schema version 24 Chrome prefixes the value with SHA-256(host_key).
        if schemaVersion >= 24, plain.count > 32 { plain = plain.dropFirst(32) }
        guard let text = String(data: plain, encoding: .utf8), !text.isEmpty else { throw ReadError.unreadable }
        return text
    }

    private static func safeStorageKey(for browser: Browser) throws -> Data {
        lock.lock()
        defer { lock.unlock() }
        if let cached = cachedKeys[browser.keychainService] { return cached }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: browser.keychainService,
            kSecAttrAccount as String: browser.keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        DiagnosticLog.write("browser: \(browser.keychainService) keychain status \(status)")
        guard status == errSecSuccess, let password = item as? Data else {
            throw ReadError.keychainDenied
        }
        let key = try deriveKey(password)
        cachedKeys[browser.keychainService] = key
        return key
    }

    private static func deriveKey(_ password: Data) throws -> Data {
        let salt = Data("saltysalt".utf8)
        var key = Data(count: kCCKeySizeAES128)
        let status = key.withUnsafeMutableBytes { keyBytes in
            salt.withUnsafeBytes { saltBytes in
                password.withUnsafeBytes { passwordBytes in
                    CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2),
                                         passwordBytes.baseAddress?.assumingMemoryBound(to: CChar.self), password.count,
                                         saltBytes.baseAddress?.assumingMemoryBound(to: UInt8.self), salt.count,
                                         CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1), 1003,
                                         keyBytes.baseAddress?.assumingMemoryBound(to: UInt8.self), kCCKeySizeAES128)
                }
            }
        }
        guard status == kCCSuccess else { throw ReadError.unreadable }
        return key
    }
}
