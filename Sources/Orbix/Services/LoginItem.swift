import Foundation
import Observation
import ServiceManagement

/// "Open at login" through macOS's own login items (`SMAppService`), so Orbix shows up in
/// System Settings → General → Login Items and can be removed from there too.
/// Orbix never adds itself: it asks once, and afterwards only the switch in Settings changes it.
@MainActor
@Observable
final class LoginItem {
    static let shared = LoginItem()

    private(set) var isEnabled = false
    /// The user must allow it in System Settings (managed Macs, or after turning it off there).
    private(set) var needsApproval = false
    private(set) var errorMessage: String?
    /// Whether the one-time question was already answered (kept in UserDefaults).
    private(set) var asked: Bool {
        didSet { UserDefaults.standard.set(asked, forKey: Self.askedKey) }
    }

    private static let askedKey = "loginItemAsked"

    private init() {
        asked = UserDefaults.standard.bool(forKey: Self.askedKey)
        refresh()
    }

    func refresh() {
        let status = SMAppService.mainApp.status
        isEnabled = status == .enabled
        needsApproval = status == .requiresApproval
    }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            errorMessage = nil
        } catch {
            errorMessage = "No se pudo cambiar: \(error.localizedDescription)"
        }
        asked = true
        refresh()
    }

    /// The one-time question in the panel: only for an installed copy that isn't registered yet,
    /// never for a development build.
    var shouldOffer: Bool {
        guard !asked, !isEnabled else { return false }
        let path = Bundle.main.bundlePath
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return path.hasPrefix("/Applications/") || path.hasPrefix(home + "/Applications/")
    }

    func declineOffer() {
        asked = true
    }

    func openSystemSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }
}
