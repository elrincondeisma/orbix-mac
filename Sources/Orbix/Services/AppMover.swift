import AppKit

/// Offers to move Orbix to Applications when it runs from somewhere Sparkle cannot update it:
/// translocated by Gatekeeper (opened straight from the dmg or from a quarantined copy),
/// from the dmg volume itself, or from Downloads. Same idea as the classic LetsMove library.
@MainActor
enum AppMover {
    static func offerIfNeeded() {
        let bundle = Bundle.main.bundleURL.resolvingSymlinksInPath()
        guard let source = originalLocation(of: bundle), needsMove(source) else { return }

        NSApp.activate()
        let alert = NSAlert()
        alert.messageText = "¿Mover Orbix a Aplicaciones?"
        alert.informativeText = "Orbix se está ejecutando fuera de la carpeta Aplicaciones, y desde ahí no puede "
            + "actualizarse sola. Se moverá y se volverá a abrir."
        alert.addButton(withTitle: "Mover a Aplicaciones")
        alert.addButton(withTitle: "Ahora no")
        guard alert.runModal() == .alertFirstButtonReturn else { return }

        do {
            let destination = try move(bundle, originallyAt: source)
            relaunch(destination, eject: volumeToEject(source))
        } catch {
            let failure = NSAlert(error: error)
            failure.messageText = "No se pudo mover Orbix"
            failure.runModal()
        }
    }

    // MARK: - Where it runs

    private static var home: URL { FileManager.default.homeDirectoryForCurrentUser }

    private static func needsMove(_ url: URL) -> Bool {
        let path = url.path
        if path.hasPrefix("/Applications/") || path.hasPrefix(home.appendingPathComponent("Applications").path + "/") {
            return false
        }
        if isTranslocated(Bundle.main.bundleURL) { return true }
        if path.hasPrefix(home.appendingPathComponent("Downloads").path + "/") { return true }
        return isOnDiskImage(url)
    }

    /// A read-only volume under /Volumes is how a mounted dmg looks.
    private static func isOnDiskImage(_ url: URL) -> Bool {
        guard url.path.hasPrefix("/Volumes/"),
              let values = try? url.resourceValues(forKeys: [.volumeIsReadOnlyKey]) else { return false }
        return values.volumeIsReadOnly ?? false
    }

    private static func volumeToEject(_ source: URL) -> URL? {
        guard isOnDiskImage(source) else { return nil }
        let parts = source.pathComponents   // ["/", "Volumes", "<name>", …]
        return parts.count > 2 ? URL(fileURLWithPath: "/Volumes/\(parts[2])") : nil
    }

    // MARK: - Translocation (Security.framework, looked up at runtime as LetsMove does)

    private typealias IsTranslocatedFn = @convention(c) (CFURL, UnsafeMutablePointer<Bool>, UnsafeMutablePointer<Unmanaged<CFError>?>?) -> Bool
    private typealias OriginalPathFn = @convention(c) (CFURL, UnsafeMutablePointer<Unmanaged<CFError>?>?) -> Unmanaged<CFURL>?

    private static let security = dlopen("/System/Library/Frameworks/Security.framework/Security", RTLD_LAZY)

    private static func isTranslocated(_ url: URL) -> Bool {
        guard let symbol = dlsym(security, "SecTranslocateIsTranslocatedURL") else {
            return url.path.contains("/AppTranslocation/")
        }
        var result = false
        _ = unsafeBitCast(symbol, to: IsTranslocatedFn.self)(url as CFURL, &result, nil)
        return result
    }

    /// Where the user actually has the app (the dmg, Downloads…) when it runs translocated.
    private static func originalLocation(of url: URL) -> URL? {
        guard isTranslocated(url) else { return url }
        guard let symbol = dlsym(security, "SecTranslocateCreateOriginalPathForURL"),
              let original = unsafeBitCast(symbol, to: OriginalPathFn.self)(url as CFURL, nil) else { return nil }
        return original.takeRetainedValue() as URL
    }

    // MARK: - Move and relaunch

    /// `ORBIX_APPLICATIONS_DIR` overrides the destination folder (only used to test this flow).
    private static func applicationsFolder() -> URL {
        if let override = ProcessInfo.processInfo.environment["ORBIX_APPLICATIONS_DIR"] {
            return URL(fileURLWithPath: override, isDirectory: true)
        }
        let system = URL(fileURLWithPath: "/Applications", isDirectory: true)
        if FileManager.default.isWritableFile(atPath: system.path) { return system }
        let user = home.appendingPathComponent("Applications", isDirectory: true)
        try? FileManager.default.createDirectory(at: user, withIntermediateDirectories: true)
        return user
    }

    private static func move(_ bundle: URL, originallyAt source: URL) throws -> URL {
        let fm = FileManager.default
        let destination = applicationsFolder().appendingPathComponent(bundle.lastPathComponent)
        // An older copy goes to the Trash rather than being deleted.
        if fm.fileExists(atPath: destination.path) {
            try fm.trashItem(at: destination, resultingItemURL: nil)
        }
        try fm.copyItem(at: bundle, to: destination)
        // Already approved and notarized: without the quarantine flag it won't be translocated again.
        _ = try? Shell.run(URL(fileURLWithPath: "/usr/bin/xattr"),
                           arguments: ["-dr", "com.apple.quarantine", destination.path], timeout: 20)
        // A copy the user downloaded to Downloads goes to the Trash; a dmg just gets ejected.
        if source.path.hasPrefix(home.appendingPathComponent("Downloads").path + "/") {
            try? fm.trashItem(at: source, resultingItemURL: nil)
        }
        DiagnosticLog.write("mover: moved to \(destination.deletingLastPathComponent().path)")
        return destination
    }

    /// Opens the moved copy once this process has quit, then ejects the dmg if it came from one.
    private static func relaunch(_ app: URL, eject volume: URL?) {
        let pid = ProcessInfo.processInfo.processIdentifier
        var script = "while kill -0 \(pid) 2>/dev/null; do sleep 0.2; done; /usr/bin/open \(quoted(app.path))"
        if let volume { script += "; /usr/bin/hdiutil detach \(quoted(volume.path)) -quiet" }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", script]
        try? process.run()
        NSApp.terminate(nil)
    }

    private static func quoted(_ text: String) -> String { "'" + text.replacingOccurrences(of: "'", with: "'\\''") + "'" }
}
