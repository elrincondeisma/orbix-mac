import AppKit

// Plain AppKit entry point: Orbix is only a status item and its popover. A SwiftUI `App`
// needs at least one scene, and the empty `Settings` scene it forced showed up as a blank
// "Orbix Settings" window.
MainActor.assumeIsolated {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.accessory)
    withExtendedLifetime(delegate) { app.run() }
}
