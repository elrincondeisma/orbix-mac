import AppKit
import Observation
import SwiftUI

@main
struct OrbixApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        // Everything lives in the status item's popover; SwiftUI needs at least one scene.
        Settings { EmptyView() }
    }
}

/// Status item + popover, as in ModelNap. `MenuBarExtra` keeps its window at the tallest
/// height it has shown, so the shorter settings view floated in empty space; a popover
/// with `preferredContentSize` resizes to whatever the panel shows.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let store = UsageStore.shared
    private var statusItem: NSStatusItem!
    private let popover = NSPopover()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.target = self
            button.action = #selector(togglePopover)
            button.imagePosition = .imageLeading
        }

        let hosting = NSHostingController(rootView: MenuContentView().environment(store))
        hosting.sizingOptions = [.preferredContentSize]
        popover.contentViewController = hosting
        popover.behavior = .transient
        popover.animates = true

        updateStatusItem()
        // Starts Sparkle's daily check for a newer release.
        _ = AppUpdater.shared
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            store.showingSettings = false
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    /// Redraws the menu bar icon whenever the store values it reads change.
    private func updateStatusItem() {
        withObservationTracking {
            guard let button = statusItem.button else { return }
            button.image = OrbixMark.statusImage(percent: store.snapshot?.session?.percent, dot: dot)
            button.title = store.headlinePercent.map { " \($0)%" } ?? ""
        } onChange: { [weak self] in
            Task { @MainActor in self?.updateStatusItem() }
        }
    }

    private var dot: OrbixMark.Dot {
        if store.isLoading && store.snapshot == nil { return .busy }
        if store.errorMessage != nil { return .error }
        if let pct = store.snapshot?.session?.percent, pct >= 90 { return .error }
        return store.snapshot == nil ? .none : .ok
    }
}
