import Foundation

/// A Claude Code profile: its own config folder (`CLAUDE_CONFIG_DIR`) and therefore its own
/// login, history and MCP servers. The main profile is the plain `~/.claude`.
struct Profile: Identifiable, Codable, Hashable, Sendable {
    enum Kind: String, Codable, Sendable {
        /// `~/.claude`, the account `claude` uses without a profile.
        case main
        /// Logged in once with `/login` inside the profile; Claude Code keeps that login.
        case login
        /// A long-lived `claude setup-token` token, passed as `CLAUDE_CODE_OAUTH_TOKEN`.
        case token
    }

    /// Folder name under `~/.claude-perfiles` and the name typed in the terminal.
    let slug: String
    let name: String
    let kind: Kind
    var id: String { slug }

    static let mainSlug = "principal"
    static let main = Profile(slug: mainSlug, name: "Principal", kind: .main)

    var isMain: Bool { kind == .main }

    /// Nil for the main profile, which must run without `CLAUDE_CONFIG_DIR`.
    var configDir: URL? {
        isMain ? nil : ProfilePaths.profilesRoot.appendingPathComponent(slug, isDirectory: true)
    }

    /// `Mi Trabajo` → `mi-trabajo`.
    static func slug(from name: String) -> String {
        let folded = name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).lowercased()
        let dashed = folded.map { $0.isLetter || $0.isNumber ? String($0) : "-" }.joined()
        return dashed.split(separator: "-").joined(separator: "-")
    }
}

enum ProfilePaths {
    static let home = FileManager.default.homeDirectoryForCurrentUser
    static let profilesRoot = home.appendingPathComponent(".claude-perfiles", isDirectory: true)
    static let orbixConfig = home.appendingPathComponent(".config/orbix", isDirectory: true)
    static let profilesFile = orbixConfig.appendingPathComponent("profiles.json")
    /// One line with the active slug; read by the shell function on every `claude`.
    static let activeFile = orbixConfig.appendingPathComponent("active-profile")
    static let shellScript = orbixConfig.appendingPathComponent("shell.zsh")
    static let zshrc = home.appendingPathComponent(".zshrc")
    /// Marks a token profile inside its folder, so the shell function needs no JSON parsing.
    static let tokenMarker = ".orbix-token"
    static let mainClaude = home.appendingPathComponent(".claude", isDirectory: true)
}

/// The environment `claude` needs for a profile. Sendable, so the CLI probe can use it off the main actor.
struct ProfileEnvironment: Sendable {
    let configDir: String?
    let tokenSlug: String?

    static let main = ProfileEnvironment(configDir: nil, tokenSlug: nil)

    init(configDir: String?, tokenSlug: String?) {
        self.configDir = configDir
        self.tokenSlug = tokenSlug
    }

    init(_ profile: Profile) {
        configDir = profile.configDir?.path
        tokenSlug = profile.kind == .token ? profile.slug : nil
    }

    /// Applies the profile to a process environment, starting from a clean slate so the
    /// main profile never inherits another profile's folder or token.
    func apply(to env: inout [String: String]) throws {
        env.removeValue(forKey: "CLAUDE_CONFIG_DIR")
        env.removeValue(forKey: "CLAUDE_CODE_OAUTH_TOKEN")
        if let configDir { env["CLAUDE_CONFIG_DIR"] = configDir }
        if let tokenSlug { env["CLAUDE_CODE_OAUTH_TOKEN"] = try ProfileTokens.read(tokenSlug) }
    }
}
