import Foundation
import Observation

enum PanelMode: String {
    case compact, full
}

enum CredentialSource: String, CaseIterable, Identifiable {
    case auto, claudeCode, cli, manual
    var id: String { rawValue }

    var label: String {
        switch self {
        case .auto: "Automático"
        case .claudeCode: "Token de Claude Code"
        case .cli: "Comando claude /usage"
        case .manual: "Credencial manual"
        }
    }
}

@MainActor
@Observable
final class UsageStore {
    static let shared = UsageStore()

    private(set) var snapshot: UsageSnapshot?
    private(set) var errorMessage: String?
    private(set) var isLoading = false
    /// Panel UI state; lives here because `@State` is unavailable without full Xcode.
    var showingSettings = false
    /// Measured height of the panel body, so the popover fits it (up to the screen) and scrolls beyond.
    var panelBodyHeight: CGFloat = 400

    /// Compact shows only the limits; full adds extras, API cost, activity and models.
    var panelMode: PanelMode {
        didSet { UserDefaults.standard.set(panelMode.rawValue, forKey: "panelMode") }
    }
    private(set) var activity: LocalActivity?
    /// Unused extras from claude.ai (free resets, prepaid balance, extra-usage room).
    private(set) var extras: WebExtras?
    private(set) var extrasError: String?

    var source: CredentialSource {
        didSet { UserDefaults.standard.set(source.rawValue, forKey: "source"); refreshNow() }
    }

    /// Minutes between automatic refreshes.
    var interval: Int {
        didSet { UserDefaults.standard.set(interval, forKey: "interval"); scheduleTimer() }
    }

    /// Read the claude.ai session from Chrome to get the extras (asks for Keychain access once).
    var chromeSessionEnabled: Bool {
        didSet {
            UserDefaults.standard.set(chromeSessionEnabled, forKey: "chromeSession")
            webSessionKey = nil
            if !chromeSessionEnabled { extras = nil; extrasError = nil }
            refreshNow()
        }
    }

    /// Cached for the app's lifetime; re-read from Chrome after a 401.
    private var webSessionKey: String?

    var manualCredential: String {
        didSet { SecretStore.save(manualCredential.trimmingCharacters(in: .whitespacesAndNewlines)) }
    }

    private var timer: Timer?

    init() {
        let defaults = UserDefaults.standard
        source = CredentialSource(rawValue: defaults.string(forKey: "source") ?? "") ?? .auto
        let saved = defaults.integer(forKey: "interval")
        interval = saved > 0 ? saved : 5
        manualCredential = SecretStore.read() ?? ""
        panelMode = PanelMode(rawValue: defaults.string(forKey: "panelMode") ?? "") ?? .compact
        chromeSessionEnabled = defaults.object(forKey: "chromeSession") as? Bool ?? true
        scheduleTimer()
        refreshNow()
    }

    /// Session percentage shown next to the menu bar icon.
    var headlinePercent: Int? {
        (snapshot?.session ?? snapshot?.weekly).map { Int($0.percent.rounded()) }
    }

    func refreshNow() {
        Task { await refresh() }
    }

    func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            snapshot = try await fetch()
            errorMessage = nil
        } catch {
            // The last good snapshot stays visible; only the error line changes.
            errorMessage = error.localizedDescription
        }
        // Local logs need no credentials, so they show up even when the quota fetch fails.
        // The 5-hour window started 5 hours before its reset time.
        let windowStart = snapshot?.session?.resetsAt.map { $0.addingTimeInterval(-5 * 3600) }
        activity = await LocalSessionScanner.shared.scan(sessionStart: windowStart)
        await refreshExtras()
        let profiles = ProfileManager.shared
        profiles.reload()
        profiles.record(snapshot, for: profiles.activeSlug)
        if profiles.hasExtraProfiles { profiles.refreshUsage() }
    }

    private func refreshExtras() async {
        do {
            guard let key = try await sessionKeyForWeb() else {
                DiagnosticLog.write("extras: no web session (chrome \(chromeSessionEnabled ? "on" : "off"))")
                extras = nil
                extrasError = nil
                return
            }
            do {
                extras = try await ClaudeWebAPI.extras(sessionKey: key)
            } catch ClaudeAPIError.unauthorized where chromeSessionEnabled {
                // The cookie rotated since it was read: read it again once.
                webSessionKey = nil
                guard let fresh = try await sessionKeyForWeb() else { return }
                extras = try await ClaudeWebAPI.extras(sessionKey: fresh)
            }
            extrasError = nil
            DiagnosticLog.write("extras: ok, resets \(extras?.resets.count ?? -1), prepaid \(extras?.prepaid != nil), overage \(extras?.overage != nil)")
        } catch {
            extrasError = error.localizedDescription
            DiagnosticLog.write("extras: error \(error)")
        }
    }

    /// A pasted sessionKey wins; otherwise Chrome's, when enabled.
    private func sessionKeyForWeb() async throws -> String? {
        let manual = manualCredential.trimmingCharacters(in: .whitespacesAndNewlines)
        if !manual.isEmpty, !manual.hasPrefix("sk-ant-oat") {
            return manual.replacingOccurrences(of: "sessionKey=", with: "")
        }
        guard chromeSessionEnabled else { return nil }
        if let webSessionKey { return webSessionKey }
        // Keychain and SQLite block; keep them off the main thread.
        let key = try await Task.detached { try ChromeSession.sessionKey() }.value
        webSessionKey = key
        return key
    }

    private func fetch() async throws -> UsageSnapshot {
        // Another profile is active: only `claude /usage` inside it knows that account's limits.
        if !ProfileManager.shared.active.isMain {
            return try await fetchWithCLI()
        }
        let manual = manualCredential.trimmingCharacters(in: .whitespacesAndNewlines)
        switch source {
        case .claudeCode:
            return try await fetchWithClaudeCode()
        case .cli:
            return try await fetchWithCLI()
        case .manual:
            return try await fetchManual(manual)
        case .auto:
            // Fastest first. The CLI works on any Mac where `claude` is logged in (it is
            // what CodexBar ends up using when the Keychain token is not readable).
            if let snapshot = try? await fetchWithClaudeCode() { return snapshot }
            do {
                return try await fetchWithCLI()
            } catch {
                guard !manual.isEmpty else { throw error }
                return try await fetchManual(manual)
            }
        }
    }

    private func fetchWithClaudeCode() async throws -> UsageSnapshot {
        // `security` blocks while it runs, so keep it off the main thread.
        let creds = try await Task.detached { try ClaudeCodeCredentials.load() }.value
        return try await fetchOAuth(token: creds.accessToken,
                                    plan: PlanName.from(creds.subscriptionType), source: "Claude Code")
    }

    private func fetchWithCLI() async throws -> UsageSnapshot {
        let profile = ProfileManager.shared.activeEnvironment
        return try await Task.detached { try ClaudeCLIUsage.fetch(profile: profile) }.value
    }

    private func fetchManual(_ credential: String) async throws -> UsageSnapshot {
        guard !credential.isEmpty else {
            throw ClaudeCodeCredentials.ReadError.notFound
        }
        if credential.hasPrefix("sk-ant-oat") {
            return try await fetchOAuth(token: credential, plan: nil, source: "Token OAuth manual")
        }
        let sessionKey = credential.replacingOccurrences(of: "sessionKey=", with: "")
        let (usage, orgName) = try await ClaudeWebAPI.usage(sessionKey: sessionKey)
        return UsageSnapshot(response: usage, account: orgName, plan: nil, source: "claude.ai (cookie)")
    }

    private func fetchOAuth(token: String, plan: String?, source: String) async throws -> UsageSnapshot {
        async let usage = ClaudeOAuthAPI.usage(token: token)
        async let profile = ClaudeOAuthAPI.profile(token: token)
        let (u, p) = try await (usage, profile)
        return UsageSnapshot(response: u, account: p.email, plan: plan ?? p.plan, source: source)
    }

    private func scheduleTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval * 60), repeats: true) { [weak self] _ in
            Task { @MainActor in await self?.refresh() }
        }
    }
}
