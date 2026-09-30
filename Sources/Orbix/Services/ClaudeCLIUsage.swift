import Foundation

/// Asks the installed `claude` for its own `/usage` report, the way CodexBar does.
/// Claude Code handles its login itself, so Orbix never touches a token.
///
/// `claude -p "/usage"` prints plain text such as:
///
///     Current session: 3% used · resets Sep 30 at 12:20pm (Europe/Madrid)
///     Current week (all models): 39% used · resets Oct 2 at 10pm (Europe/Madrid)
///     Current week (Fable): 0% used · resets Oct 2 at 9:59pm (Europe/Madrid)
enum ClaudeCLIUsage {
    enum CLIError: LocalizedError {
        case notInstalled
        case timedOut
        case unparseable(String)

        var errorDescription: String? {
            switch self {
            case .notInstalled: "No se encontró el comando `claude`. Instala Claude Code."
            case .timedOut: "`claude /usage` no respondió a tiempo."
            case let .unparseable(output):
                output.isEmpty ? "`claude /usage` no devolvió nada." : "`claude /usage`: \(output.prefix(200))"
            }
        }
    }

    static func fetch() throws -> UsageSnapshot {
        guard let binary = findBinary() else { throw CLIError.notInstalled }
        let output = try run(binary, arguments: [
            "-p", "/usage",
            // Same safety flags as CodexBar: no tools, no MCP servers, no Remote Control.
            "--allowed-tools", "", "--strict-mcp-config",
            "--settings", #"{"remoteControlAtStartup":false}"#,
            // Keeps these probes out of ~/.claude/projects (and out of the local activity).
            "--no-session-persistence",
        ])
        return try parse(output)
    }

    static func parse(_ output: String, now: Date = Date()) throws -> UsageSnapshot {
        var session: UsageBar?
        var weekly: UsageBar?
        var models: [UsageBar] = []

        for rawLine in output.split(whereSeparator: \.isNewline) {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            guard let match = line.firstMatch(of: /^Current (session|week)(?: \((.+?)\))?: (\d+(?:\.\d+)?)% used(?: · resets (.+?)(?: \((.+)\))?)?$/)
            else { continue }
            let percent = Double(match.3) ?? 0
            let reset = match.4.flatMap { ResetParser.date(String($0), timeZone: match.5.map(String.init), now: now) }

            if match.1 == "session" {
                session = UsageBar(id: "session", title: "Sesión (5 h)", percent: percent, resetsAt: reset)
            } else if let scope = match.2.map(String.init), scope.lowercased() != "all models" {
                models.append(UsageBar(id: "model-\(scope)", title: "\(scope) · semanal", percent: percent, resetsAt: reset))
            } else {
                weekly = UsageBar(id: "weekly", title: "Semanal", percent: percent, resetsAt: reset)
            }
        }

        guard session != nil || weekly != nil else {
            throw CLIError.unparseable(output.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        return UsageSnapshot(session: session, weekly: weekly, models: models, source: "claude /usage")
    }

    // MARK: - Process

    /// Apps launched from Finder get a minimal PATH, so check the usual install locations
    /// and fall back to asking a login shell.
    private static func findBinary() -> URL? {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let candidates = ["\(home)/.local/bin/claude", "\(home)/.claude/local/claude",
                          "/opt/homebrew/bin/claude", "/usr/local/bin/claude"]
        if let found = candidates.first(where: { FileManager.default.isExecutableFile(atPath: $0) }) {
            return URL(fileURLWithPath: found)
        }
        let path = try? run(URL(fileURLWithPath: "/bin/zsh"), arguments: ["-lc", "command -v claude"], timeout: 10)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let path, !path.isEmpty, FileManager.default.isExecutableFile(atPath: path) else { return nil }
        return URL(fileURLWithPath: path)
    }

    private static func run(_ executable: URL, arguments: [String], timeout: TimeInterval = 60) throws -> String {
        let process = Process()
        process.executableURL = executable
        process.arguments = arguments
        process.currentDirectoryURL = probeDirectory()
        var env = ProcessInfo.processInfo.environment
        // An API key in the environment would make `claude` bill the API instead of the subscription.
        env.removeValue(forKey: "ANTHROPIC_API_KEY")
        process.environment = env

        let out = Pipe()
        process.standardOutput = out
        process.standardError = out
        process.standardInput = FileHandle.nullDevice
        try process.run()

        // Read while it runs so a full pipe buffer cannot block the child.
        let output = OutputBox()
        let done = DispatchSemaphore(value: 0)
        DispatchQueue(label: "orbix.cli.reader").async {
            output.data = out.fileHandleForReading.readDataToEndOfFile()
            done.signal()
        }
        if done.wait(timeout: .now() + timeout) == .timedOut {
            process.terminate()
            throw CLIError.timedOut
        }
        process.waitUntilExit()
        return String(decoding: output.data, as: UTF8.self)
    }

    /// Written once by the reader queue and read only after the semaphore fires.
    private final class OutputBox: @unchecked Sendable {
        var data = Data()
    }

    private static func probeDirectory() -> URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Orbix/ClaudeProbe")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
}

/// Turns `Sep 30 at 12:20pm` / `Oct 2 at 10pm` / `12:20pm` into a date in the given time zone.
enum ResetParser {
    static func date(_ text: String, timeZone name: String?, now: Date) -> Date? {
        let tz = name.flatMap(TimeZone.init(identifier:)) ?? .current
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = tz

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = tz
        formatter.defaultDate = calendar.startOfDay(for: now)

        let cleaned = text.replacingOccurrences(of: " at ", with: " ").lowercased()
        for format in ["MMM d h:mma", "MMM d ha", "h:mma", "ha"] {
            formatter.dateFormat = format
            guard var date = formatter.date(from: cleaned) else { continue }
            // The report omits the year (and, for today, the day); resets are always in the future.
            if format.hasPrefix("MMM") {
                var parts = calendar.dateComponents([.month, .day, .hour, .minute], from: date)
                parts.year = calendar.component(.year, from: now)
                date = calendar.date(from: parts) ?? date
                if date < now.addingTimeInterval(-86_400) {
                    date = calendar.date(byAdding: .year, value: 1, to: date) ?? date
                }
            } else if date < now {
                date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
            }
            return date
        }
        return nil
    }
}
