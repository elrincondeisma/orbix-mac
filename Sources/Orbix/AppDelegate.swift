import AppKit
import Observation
import SwiftUI

/// Status item + popover, as in ModelNap. `MenuBarExtra` keeps its window at the tallest
/// height it has shown, so the shorter settings view floated in empty space; a popover
/// with `preferredContentSize` resizes to whatever the panel shows.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let store = UsageStore.shared
    private var statusItem: NSStatusItem!
    private let popover = NSPopover()

    func applicationDidFinishLaunching(_ notification: Notification) {
        installEditMenu()
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
        // Before Sparkle starts: from the dmg or a translocated copy it could not update itself.
        AppMover.offerIfNeeded()
        // Starts Sparkle's daily check for a newer release.
        _ = AppUpdater.shared
    }

    /// Never shown (Orbix has no menu bar of its own), but its key equivalents are what make
    /// ⌘C / ⌘V / ⌘X / ⌘A / ⌘Z work in the settings text fields.
    private func installEditMenu() {
        let edit = NSMenu(title: "Edición")
        edit.addItem(withTitle: "Deshacer", action: Selector(("undo:")), keyEquivalent: "z")
        edit.addItem(withTitle: "Rehacer", action: Selector(("redo:")), keyEquivalent: "Z")
        edit.addItem(.separator())
        edit.addItem(withTitle: "Cortar", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        edit.addItem(withTitle: "Copiar", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        edit.addItem(withTitle: "Pegar", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        edit.addItem(withTitle: "Seleccionar todo", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        let editItem = NSMenuItem(title: "Edición", action: nil, keyEquivalent: "")
        editItem.submenu = edit
        let main = NSMenu()
        main.addItem(NSMenuItem(title: "Orbix", action: nil, keyEquivalent: ""))
        main.addItem(editItem)
        NSApp.mainMenu = main
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            store.showingSettings = false
            ProfileManager.shared.reload()
            LoginItem.shared.refresh()
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
