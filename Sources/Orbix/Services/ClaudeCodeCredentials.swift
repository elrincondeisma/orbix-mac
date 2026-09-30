import Foundation

/// Reads the OAuth token that Claude Code (`claude login`) already stores on this Mac.
///
/// Read-only on purpose: Orbix never refreshes the token, because refreshing rotates the
/// refresh token and would log Claude Code out. When it expires, running `claude` renews it.
enum ClaudeCodeCredentials {
    struct OAuth: Sendable {
        let accessToken: String
        let expiresAt: Date?
        let subscriptionType: String?
        let scopes: [String]
    }

    enum ReadError: LocalizedError {
        case notFound
        case noClaudeAiOAuth
        case expired
        case missingScope

        var errorDescription: String? {
            switch self {
            case .notFound:
                "No se encontró la sesión de Claude Code. Ejecuta `claude` e inicia sesión, o pega una credencial en Ajustes."
            case .noClaudeAiOAuth:
                "Claude Code no guarda aquí el token de claude.ai (solo MCP). Usa una credencial manual en Ajustes."
            case .expired:
                "El token de Claude Code ha caducado. Abre `claude` en la terminal para renovarlo."
            case .missingScope:
                "El token no tiene el permiso `user:profile` necesario para leer el uso."
            }
        }
    }

    static let keychainService = "Claude Code-credentials"

    static func load() throws -> OAuth {
        guard let data = readFile() ?? readKeychain() else { throw ReadError.notFound }
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ReadError.notFound
        }
        guard let oauth = root["claudeAiOauth"] as? [String: Any],
              let token = oauth["accessToken"] as? String, !token.isEmpty else {
            throw ReadError.noClaudeAiOAuth
        }
        let expiresAt = (oauth["expiresAt"] as? Double).map { Date(timeIntervalSince1970: $0 / 1000) }
        if let expiresAt, expiresAt < Date() { throw ReadError.expired }
        let scopes = oauth["scopes"] as? [String] ?? []
        if !scopes.isEmpty, !scopes.contains("user:profile") { throw ReadError.missingScope }
        return OAuth(accessToken: token, expiresAt: expiresAt,
                     subscriptionType: oauth["subscriptionType"] as? String, scopes: scopes)
    }

    /// `~/.claude/.credentials.json` (or `$CLAUDE_CONFIG_DIR/.credentials.json`), used on setups without Keychain.
    private static func readFile() -> Data? {
        let env = ProcessInfo.processInfo.environment
        let dir = env["CLAUDE_CONFIG_DIR"].map { URL(fileURLWithPath: $0) }
            ?? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".claude")
        return try? Data(contentsOf: dir.appendingPathComponent(".credentials.json"))
    }

    /// Goes through `/usr/bin/security`, the same tool Claude Code uses to write the item,
    /// so it is usually already in the item's ACL and does not trigger a Keychain prompt.
    private static func readKeychain() -> Data? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/security")
        process.arguments = ["find-generic-password", "-s", keychainService, "-w"]
        let out = Pipe()
        process.standardOutput = out
        process.standardError = FileHandle.nullDevice
        do { try process.run() } catch { return nil }
        let data = out.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else { return nil }
        let trimmed = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : Data(trimmed.utf8)
    }
}
