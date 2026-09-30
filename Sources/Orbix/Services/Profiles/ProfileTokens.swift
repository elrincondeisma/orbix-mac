import Foundation

/// Long-lived tokens that the user pastes for token profiles, kept in the login Keychain.
///
/// Written and read through `/usr/bin/security`, the same tool the shell function uses:
/// an item created by `security` is readable by `security` without a Keychain prompt,
/// both from Orbix and from every new terminal.
enum ProfileTokens {
    static let service = "dev.orbix.profile-token"

    enum TokenError: LocalizedError {
        case invalid
        case missing(String)
        case keychain(String)

        var errorDescription: String? {
            switch self {
            case .invalid: "No parece un token de larga duración (empieza por sk-ant-oat…). Se genera con `claude setup-token`."
            case let .missing(slug): "No encuentro el token del perfil «\(slug)» en el Llavero."
            case let .keychain(message): "Llavero: \(message)"
            }
        }
    }

    static func save(_ token: String, for slug: String) throws {
        let token = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard token.hasPrefix("sk-ant-oat"), !token.contains(where: \.isWhitespace) else { throw TokenError.invalid }
        // Interactive mode reads the command from stdin, so the token never shows up in `ps`.
        let hex = token.utf8.map { String(format: "%02x", $0) }.joined()
        let command = "add-generic-password -U -a \"\(slug)\" -s \"\(service)\" -X \(hex)\n"
        let (status, output) = try Shell.run(URL(fileURLWithPath: "/usr/bin/security"), arguments: ["-i"],
                                             stdin: Data(command.utf8), timeout: 10)
        guard status == 0, !output.localizedCaseInsensitiveContains("error") else {
            throw TokenError.keychain(output.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }

    static func read(_ slug: String) throws -> String {
        let (status, output) = try Shell.run(URL(fileURLWithPath: "/usr/bin/security"),
                                             arguments: ["find-generic-password", "-a", slug, "-s", service, "-w"],
                                             timeout: 10)
        guard status == 0 else { throw TokenError.missing(slug) }
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func delete(_ slug: String) {
        _ = try? Shell.run(URL(fileURLWithPath: "/usr/bin/security"),
                           arguments: ["delete-generic-password", "-a", slug, "-s", service], timeout: 10)
    }
}
