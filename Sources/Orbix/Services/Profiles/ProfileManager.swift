import AppKit
import Foundation
import Observation

/// Claude Code profiles: which exist, which is active, and each one's limits.
@MainActor
@Observable
final class ProfileManager {
    static let shared = ProfileManager()

    private(set) var profiles: [Profile] = [.main]
    private(set) var activeSlug = Profile.mainSlug
    /// Limits per profile, from `claude /usage` run inside each one.
    private(set) var usage: [String: UsageSnapshot] = [:]
    private(set) var usageErrors: [String: String] = [:]
    private(set) var shellInstalled = ProfileShell.isInstalled
    /// Outcome of the last action; fades after a few seconds.
    private(set) var message: String? {
        didSet {
            guard let message else { return }
            messageTask?.cancel()
            messageTask = Task { [weak self] in
                try? await Task.sleep(for: .seconds(6))
                guard !Task.isCancelled, self?.message == message else { return }
                self?.message = nil
            }
        }
    }
    @ObservationIgnored private var messageTask: Task<Void, Never>?
    private(set) var busy = false

    /// Also point GUI apps (VS Code…) at the active profile via `launchctl setenv`.
    var applyToApps: Bool {
        didSet {
            UserDefaults.standard.set(applyToApps, forKey: "profilesApplyToApps")
            syncLaunchEnvironment()
        }
    }

    // New-profile form (settings); here because `@State` is unavailable without full Xcode.
    var newName = ""
    var newKind: Profile.Kind = .login
    var newToken = ""
    var newShareHistory = false

    var active: Profile { profiles.first { $0.slug == activeSlug } ?? .main }
    var hasExtraProfiles: Bool { profiles.count > 1 }

    private init() {
        applyToApps = UserDefaults.standard.bool(forKey: "profilesApplyToApps")
        ProfileShell.writeScript()
        reload()
    }

    /// Re-reads the list and the active profile (`orbix-perfil` may have changed it in a terminal).
    func reload() {
        var list: [Profile] = [.main]
        if let data = try? Data(contentsOf: ProfilePaths.profilesFile),
           let saved = try? JSONDecoder().decode([Profile].self, from: data) {
            list += saved.filter { !$0.isMain && FileManager.default.fileExists(atPath: $0.configDir!.path) }
        }
        profiles = list
        list.filter { $0.kind == .token }.forEach(markOnboarded)
        let slug = (try? String(contentsOf: ProfilePaths.activeFile, encoding: .utf8))?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? Profile.mainSlug
        activeSlug = list.contains { $0.slug == slug } ? slug : Profile.mainSlug
        shellInstalled = ProfileShell.isInstalled
    }

    // MARK: - Active profile

    func activate(_ profile: Profile) {
        guard profile.slug != activeSlug else { return }
        do {
            try FileManager.default.createDirectory(at: ProfilePaths.orbixConfig, withIntermediateDirectories: true)
            try (profile.slug + "\n").write(to: ProfilePaths.activeFile, atomically: true, encoding: .utf8)
            activeSlug = profile.slug
            syncLaunchEnvironment()
            message = shellInstalled
                ? "Los `claude` que abras ahora usan \(profile.name)."
                : "Activo: \(profile.name). Activa la integración con la terminal en Ajustes para que `claude` lo use."
        } catch {
            message = "No se pudo cambiar el perfil: \(error.localizedDescription)"
        }
    }

    var activeEnvironment: ProfileEnvironment { ProfileEnvironment(active) }

    /// GUI apps don't read ~/.zshrc; `launchctl setenv` reaches the apps opened afterwards.
    /// Tokens are never exported this way: every app would see them.
    private func syncLaunchEnvironment() {
        let launchctl = URL(fileURLWithPath: "/bin/launchctl")
        let dir = active.configDir?.path
        if applyToApps, let dir, active.kind == .login {
            _ = try? Shell.run(launchctl, arguments: ["setenv", "CLAUDE_CONFIG_DIR", dir], timeout: 5)
        } else {
            _ = try? Shell.run(launchctl, arguments: ["unsetenv", "CLAUDE_CONFIG_DIR"], timeout: 5)
        }
    }

    // MARK: - Create / remove

    func createProfile() {
        let name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        let slug = Profile.slug(from: name)
        guard !slug.isEmpty else { message = "Ponle un nombre al perfil."; return }
        guard slug != Profile.mainSlug, !profiles.contains(where: { $0.slug == slug }) else {
            message = "Ya hay un perfil «\(slug)»."
            return
        }
        let profile = Profile(slug: slug, name: name, kind: newKind)
        do {
            if newKind == .token { try ProfileTokens.save(newToken, for: slug) }
            try createFolder(for: profile, shareHistory: newShareHistory)
            try save(profiles.filter { !$0.isMain } + [profile])
            reload()
            newName = ""; newToken = ""; newShareHistory = false
            if profile.kind == .login {
                message = "Perfil «\(slug)» creado. En la Terminal que se abre, escribe /login y entra con la otra cuenta."
                openClaude(in: profile)
            } else {
                message = "Perfil «\(slug)» creado con su token."
            }
            refreshUsage()
        } catch {
            if newKind == .token { ProfileTokens.delete(slug) }
            message = error.localizedDescription
        }
    }

    /// Removes the profile from Orbix and its token from the Keychain. The folder stays on disk
    /// (it holds that account's history and Claude Code's own login), so nothing is lost by accident.
    func remove(_ profile: Profile) {
        guard !profile.isMain else { return }
        if profile.slug == activeSlug { activate(.main) }
        if profile.kind == .token { ProfileTokens.delete(profile.slug) }
        try? save(profiles.filter { !$0.isMain && $0.slug != profile.slug })
        // Without Orbix's list the folder would still be picked by the shell function; rename it aside.
        if let dir = profile.configDir {
            let parked = dir.deletingLastPathComponent().appendingPathComponent(".\(profile.slug)-quitado-\(Int(Date().timeIntervalSince1970))")
            try? FileManager.default.moveItem(at: dir, to: parked)
            message = "Perfil «\(profile.slug)» quitado. Su carpeta queda en \(parked.path.replacingOccurrences(of: ProfilePaths.home.path, with: "~"))."
        }
        usage[profile.slug] = nil
        reload()
    }

    private func save(_ list: [Profile]) throws {
        try FileManager.default.createDirectory(at: ProfilePaths.orbixConfig, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(list)
        try data.write(to: ProfilePaths.profilesFile, options: .atomic)
    }

    /// Settings, instructions, skills, commands and agents are shared with ~/.claude through
    /// symlinks; history too when asked. Login, `.claude.json` and MCP servers stay per profile.
    private func createFolder(for profile: Profile, shareHistory: Bool) throws {
        guard let dir = profile.configDir else { return }
        let fm = FileManager.default
        try fm.createDirectory(at: dir, withIntermediateDirectories: true,
                               attributes: [.posixPermissions: 0o700])
        var shared = ["settings.json", "keybindings.json", "CLAUDE.md", "skills", "commands", "agents"]
        if shareHistory { shared += ["projects", "history.jsonl"] }
        for name in shared {
            let source = ProfilePaths.mainClaude.appendingPathComponent(name)
            let link = dir.appendingPathComponent(name)
            guard fm.fileExists(atPath: source.path), !fm.fileExists(atPath: link.path) else { continue }
            try fm.createSymbolicLink(at: link, withDestinationURL: source)
        }
        if profile.kind == .token {
            try Data().write(to: dir.appendingPathComponent(ProfilePaths.tokenMarker))
            markOnboarded(profile)
        }
    }

    /// A fresh config folder makes Claude Code run its first-launch wizard, which ends in the
    /// login screen even when `CLAUDE_CODE_OAUTH_TOKEN` is set. Token profiles never log in,
    /// so mark onboarding as done (and reuse the main theme). Other keys are left untouched.
    private func markOnboarded(_ profile: Profile) {
        guard let dir = profile.configDir else { return }
        let file = dir.appendingPathComponent(".claude.json")
        var config = (try? Data(contentsOf: file))
            .flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] } ?? [:]
        // An unreadable existing file is left alone rather than replaced.
        if FileManager.default.fileExists(atPath: file.path), config.isEmpty { return }
        guard config["hasCompletedOnboarding"] as? Bool != true else { return }
        config["hasCompletedOnboarding"] = true
        if config["theme"] == nil,
           let data = try? Data(contentsOf: ProfilePaths.home.appendingPathComponent(".claude.json")),
           let main = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let theme = main["theme"] as? String {
            config["theme"] = theme
        }
        guard let data = try? JSONSerialization.data(withJSONObject: config, options: [.prettyPrinted, .sortedKeys]) else { return }
        try? data.write(to: file, options: .atomic)
        try? FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: file.path)
        DiagnosticLog.write("profiles: \(profile.slug) marked onboarded")
    }

    // MARK: - Terminal and shell

    /// Opens a new Terminal window running `claude` as this profile, via a `.command` file
    /// (no Automation permission needed, unlike scripting Terminal).
    func openClaude(in profile: Profile) {
        guard let claude = ClaudeCLIUsage.claudePath() else {
            message = "No se encontró el comando `claude`."
            return
        }
        var lines = ["#!/bin/zsh", "cd ~", "unset CLAUDE_CONFIG_DIR CLAUDE_CODE_OAUTH_TOKEN"]
        if let dir = profile.configDir { lines.append("export CLAUDE_CONFIG_DIR=\(quoted(dir.path))") }
        if profile.kind == .token {
            lines.append("export CLAUDE_CODE_OAUTH_TOKEN=\"$(/usr/bin/security find-generic-password -a \(quoted(profile.slug)) -s \(ProfileTokens.service) -w)\"")
        }
        lines.append("echo \"Orbix · perfil \(profile.name)\"")
        lines.append("exec \(quoted(claude))")
        let file = ProfilePaths.orbixConfig.appendingPathComponent("abrir-\(profile.slug).command")
        do {
            try FileManager.default.createDirectory(at: ProfilePaths.orbixConfig, withIntermediateDirectories: true)
            try (lines.joined(separator: "\n") + "\n").write(to: file, atomically: true, encoding: .utf8)
            try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: file.path)
            NSWorkspace.shared.open(file)
        } catch {
            message = "No se pudo abrir la Terminal: \(error.localizedDescription)"
        }
    }

    func installShell() {
        do {
            ProfileShell.writeScript()
            try ProfileShell.install()
            shellInstalled = true
            message = "Listo. Abre una terminal nueva: `claude` usará el perfil activo."
        } catch {
            message = "No se pudo modificar ~/.zshrc: \(error.localizedDescription)"
        }
    }

    private func quoted(_ text: String) -> String { "'" + text.replacingOccurrences(of: "'", with: "'\\''") + "'" }

    // MARK: - Usage per profile

    /// Runs `claude /usage` in every profile except the active one (the main store already did it).
    func refreshUsage() {
        guard !busy else { return }
        busy = true
        let targets = profiles.filter { $0.slug != activeSlug }
        Task {
            await withTaskGroup(of: (String, Result<UsageSnapshot, Error>).self) { group in
                for profile in targets {
                    let env = ProfileEnvironment(profile)
                    group.addTask {
                        (profile.slug, Result { try ClaudeCLIUsage.fetch(profile: env) })
                    }
                }
                for await (slug, result) in group {
                    switch result {
                    case let .success(snapshot):
                        usage[slug] = snapshot
                        usageErrors[slug] = nil
                    case let .failure(error):
                        usageErrors[slug] = error.localizedDescription
                    }
                }
            }
            busy = false
        }
    }

    /// The main store measures the active profile; keep its figures here too.
    func record(_ snapshot: UsageSnapshot?, for slug: String) {
        usage[slug] = snapshot
    }
}

#if DEBUG
extension ProfileManager {
    /// Two demo accounts for website screenshots (debug builds only).
    func loadDemo(active: String = Profile.mainSlug) {
        let work = Profile(slug: "trabajo", name: "Trabajo", kind: .login)
        let ci = Profile(slug: "ci", name: "Integración continua", kind: .token)
        profiles = [.main, work, ci]
        activeSlug = active
        usage = [
            "trabajo": UsageSnapshot(session: UsageBar(id: "session", title: "Sesión (5 h)", percent: 71, resetsAt: nil),
                                     weekly: UsageBar(id: "weekly", title: "Semanal", percent: 83, resetsAt: nil),
                                     models: [], source: "claude /usage"),
        ]
        usageErrors = [:]
        message = nil
    }

    func recordDemo(_ snapshot: UsageSnapshot?) { usage[activeSlug] = snapshot }
}
#endif
