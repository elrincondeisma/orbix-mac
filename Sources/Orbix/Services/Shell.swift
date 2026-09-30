import Foundation

/// Runs a process with a timeout, capturing stdout and stderr together.
enum Shell {
    static func run(_ executable: URL, arguments: [String], stdin: Data? = nil,
                    environment: [String: String]? = nil, timeout: TimeInterval) throws -> (Int32, String) {
        let process = Process()
        process.executableURL = executable
        process.arguments = arguments
        var env = ProcessInfo.processInfo.environment
        // Apps opened from Finder get a minimal PATH; claude lives in ~/.local/bin.
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        env["PATH"] = "\(home)/.local/bin:/opt/homebrew/bin:/usr/local/bin:" + (env["PATH"] ?? "/usr/bin:/bin")
        env["NO_COLOR"] = "1"
        environment?.forEach { env[$0.key] = $0.value }
        process.environment = env
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        let input = Pipe()
        process.standardInput = stdin == nil ? FileHandle.nullDevice : input
        try process.run()
        if let stdin {
            input.fileHandleForWriting.write(stdin)
            try? input.fileHandleForWriting.close()
        }

        let box = OutputBox()
        let done = DispatchSemaphore(value: 0)
        DispatchQueue(label: "orbix.shell.reader").async {
            box.data = pipe.fileHandleForReading.readDataToEndOfFile()
            done.signal()
        }
        if done.wait(timeout: .now() + timeout) == .timedOut {
            process.terminate()
            throw ShellError.timedOut(executable.lastPathComponent)
        }
        process.waitUntilExit()
        return (process.terminationStatus, String(decoding: box.data, as: UTF8.self))
    }

    /// Written once by the reader queue and read only after the semaphore fires.
    private final class OutputBox: @unchecked Sendable {
        var data = Data()
    }
}

enum ShellError: LocalizedError {
    case timedOut(String)

    var errorDescription: String? {
        switch self {
        case let .timedOut(name): "\(name) no respondió a tiempo."
        }
    }
}
