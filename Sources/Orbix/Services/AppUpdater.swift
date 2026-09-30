import Foundation
import Observation
import Sparkle

/// Self-updates with Sparkle: reads the appcast from the latest GitHub release, verifies the
/// EdDSA signature of the download, replaces the app and relaunches it.
@MainActor
@Observable
final class AppUpdater {
    static let shared = AppUpdater()

    /// Nil when running outside a packaged Orbix.app (`swift run`), which has no feed URL.
    @ObservationIgnored private let controller: SPUStandardUpdaterController?

    var automaticallyChecks: Bool {
        didSet { controller?.updater.automaticallyChecksForUpdates = automaticallyChecks }
    }

    var isAvailable: Bool { controller != nil }

    var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "dev"
    }

    private init() {
        if Bundle.main.object(forInfoDictionaryKey: "SUFeedURL") != nil {
            controller = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        } else {
            controller = nil
        }
        automaticallyChecks = controller?.updater.automaticallyChecksForUpdates ?? false
    }

    func checkForUpdates() {
        controller?.checkForUpdates(nil)
    }
}
