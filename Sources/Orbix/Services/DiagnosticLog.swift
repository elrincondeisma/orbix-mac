import Foundation

/// Plain diagnostic log at ~/Library/Logs/Orbix.log. Only states and status codes:
/// never cookies, tokens or keys.
enum DiagnosticLog {
    private static let url = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Logs/Orbix.log")
    /// The previous log, kept once the current one passes `maxBytes`.
    private static let previousURL = url.deletingPathExtension().appendingPathExtension("1.log")
    private static let maxBytes: UInt64 = 1_000_000
    private static let queue = DispatchQueue(label: "orbix.log")

    static func write(_ message: String) {
        let line = "\(Date().formatted(.iso8601)) \(message)\n"
        queue.async {
            guard let data = line.data(using: .utf8) else { return }
            rotateIfNeeded()
            if let handle = try? FileHandle(forWritingTo: url) {
                handle.seekToEndOfFile()
                handle.write(data)
                try? handle.close()
            } else {
                try? data.write(to: url)
            }
        }
    }

    /// Refreshes every few minutes for months: keep at most two files of about 1 MB.
    private static func rotateIfNeeded() {
        let fm = FileManager.default
        guard let size = (try? fm.attributesOfItem(atPath: url.path))?[.size] as? UInt64,
              size > maxBytes else { return }
        try? fm.removeItem(at: previousURL)
        try? fm.moveItem(at: url, to: previousURL)
    }
}
