import Foundation

/// Plain diagnostic log at ~/Library/Logs/Orbix.log. Only states and status codes:
/// never cookies, tokens or keys.
enum DiagnosticLog {
    private static let url = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Logs/Orbix.log")
    private static let queue = DispatchQueue(label: "orbix.log")

    static func write(_ message: String) {
        let line = "\(Date().formatted(.iso8601)) \(message)\n"
        queue.async {
            guard let data = line.data(using: .utf8) else { return }
            if let handle = try? FileHandle(forWritingTo: url) {
                handle.seekToEndOfFile()
                handle.write(data)
                try? handle.close()
            } else {
                try? data.write(to: url)
            }
        }
    }
}
