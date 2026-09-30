import Foundation

/// Token activity read from Claude Code's own session logs (`~/.claude/projects/**/*.jsonl`).
/// Needs no credentials: every assistant line carries `message.model`, `timestamp` and `message.usage`.
struct LocalActivity: Sendable {
    struct Day: Identifiable, Sendable {
        let date: Date
        var tokens = 0
        var outputTokens = 0
        var messages = 0
        var sessions = Set<String>()
        var cost = 0.0
        var id: Date { date }
    }

    var days: [Day]                // last 7 days, oldest first, including empty ones
    var modelsLast7: [ModelUsage]

    struct ModelUsage: Sendable {
        let name: String
        let tokens: Int
        let cost: Double
    }

    /// What the usage would have cost on the Claude API (list prices, USD).
    var cost30Days = 0.0
    var costSessionWindow = 0.0
    var sessionWindowStart: Date
    /// Responses whose model has no known price, so the costs above leave them out.
    var unpricedResponses = 0

    var today: Day? { days.last }
    var week: (tokens: Int, output: Int, messages: Int, sessions: Int) {
        (days.reduce(0) { $0 + $1.tokens },
         days.reduce(0) { $0 + $1.outputTokens },
         days.reduce(0) { $0 + $1.messages },
         days.reduce(into: Set<String>()) { $0.formUnion($1.sessions) }.count)
    }
}

actor LocalSessionScanner {
    static let shared = LocalSessionScanner()

    /// One deduplicated assistant response.
    private struct Entry: Sendable {
        let key: String
        let date: Date
        let model: String
        let session: String
        let tokens: Int
        let output: Int
        let cost: Double?
    }

    /// Parsed files, reused while their modification date and size do not change.
    private var cache: [URL: (stamp: String, entries: [Entry])] = [:]

    private var root: URL {
        let env = ProcessInfo.processInfo.environment
        let base = env["CLAUDE_CONFIG_DIR"].map { URL(fileURLWithPath: $0) }
            ?? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".claude")
        return base.appendingPathComponent("projects")
    }

    /// - Parameter sessionStart: start of the current 5-hour window (from `/usage`); defaults to 5 hours ago.
    func scan(days dayCount: Int = 7, sessionStart: Date? = nil) -> LocalActivity {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let since = calendar.date(byAdding: .day, value: -(dayCount - 1), to: startOfToday)!
        let since30 = now.addingTimeInterval(-30 * 86_400)
        let windowStart = sessionStart ?? now.addingTimeInterval(-5 * 3600)
        var cost30 = 0.0, costWindow = 0.0, unpriced = 0

        var byDay: [Date: LocalActivity.Day] = [:]
        for offset in 0..<dayCount {
            let d = calendar.date(byAdding: .day, value: offset, to: since)!
            byDay[d] = LocalActivity.Day(date: d)
        }
        var models: [String: (tokens: Int, cost: Double)] = [:]
        // Claude Code writes one line per content block with the same usage; resumed and
        // subagent sessions can repeat them too. `message.id + requestId` identifies a response.
        var seen = Set<String>()

        for file in recentFiles(since: min(since, since30)) {
            for entry in entries(for: file) where entry.date >= since30 && seen.insert(entry.key).inserted {
                if let cost = entry.cost {
                    cost30 += cost
                    if entry.date >= windowStart { costWindow += cost }
                } else {
                    unpriced += 1
                }
                guard entry.date >= since else { continue }
                let day = calendar.startOfDay(for: entry.date)
                byDay[day]?.cost += entry.cost ?? 0
                byDay[day]?.tokens += entry.tokens
                byDay[day]?.outputTokens += entry.output
                byDay[day]?.messages += 1
                byDay[day]?.sessions.insert(entry.session)
                models[entry.model, default: (0, 0)].tokens += entry.tokens
                models[entry.model, default: (0, 0)].cost += entry.cost ?? 0
            }
        }

        let sortedModels = models
            .map { LocalActivity.ModelUsage(name: $0.key, tokens: $0.value.tokens, cost: $0.value.cost) }
            .sorted { $0.tokens > $1.tokens }
        return LocalActivity(days: byDay.values.sorted { $0.date < $1.date }, modelsLast7: sortedModels,
                             cost30Days: cost30, costSessionWindow: costWindow,
                             sessionWindowStart: windowStart, unpricedResponses: unpriced)
    }

    private func recentFiles(since: Date) -> [URL] {
        let keys: [URLResourceKey] = [.contentModificationDateKey, .fileSizeKey]
        guard let walker = FileManager.default.enumerator(at: root, includingPropertiesForKeys: keys) else { return [] }
        var files: [URL] = []
        for case let url as URL in walker where url.pathExtension == "jsonl" {
            let values = try? url.resourceValues(forKeys: Set(keys))
            if let modified = values?.contentModificationDate, modified >= since { files.append(url) }
        }
        let alive = Set(files)
        cache = cache.filter { alive.contains($0.key) }
        return files
    }

    private func entries(for file: URL) -> [Entry] {
        let values = try? file.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey])
        let stamp = "\(values?.contentModificationDate?.timeIntervalSince1970 ?? 0)-\(values?.fileSize ?? 0)"
        if let cached = cache[file], cached.stamp == stamp { return cached.entries }

        guard let data = try? Data(contentsOf: file, options: .mappedIfSafe) else { return [] }
        let decoder = JSONDecoder()
        var result: [Entry] = []

        for line in Self.candidateLines(in: data) {
            guard let row = try? decoder.decode(Row.self, from: line),
                  row.type == "assistant",
                  let message = row.message, let usage = message.usage,
                  message.model != "<synthetic>",
                  let date = ISO8601.parse(row.timestamp) else { continue }
            let id = message.id ?? row.uuid ?? UUID().uuidString
            let input = (usage.input_tokens ?? 0) + (usage.cache_creation_input_tokens ?? 0)
                + (usage.cache_read_input_tokens ?? 0)
            let output = usage.output_tokens ?? 0
            let model = message.model ?? "desconocido"
            let written = usage.cache_creation_input_tokens ?? 0
            // Older logs lack the TTL breakdown; the 5-minute TTL is the default.
            let written1h = min(usage.cache_creation?.ephemeral_1h_input_tokens ?? 0, written)
            let cost = APIPricing.cost(model: model, input: usage.input_tokens ?? 0, output: output,
                                       cacheRead: usage.cache_read_input_tokens ?? 0,
                                       cacheWrite5m: written - written1h, cacheWrite1h: written1h,
                                       fast: usage.speed == "fast")
            result.append(Entry(key: "\(id)|\(row.requestId ?? "")", date: date, model: model,
                                session: row.sessionId ?? file.lastPathComponent,
                                tokens: input + output, output: output, cost: cost))
        }
        cache[file] = (stamp, result)
        return result
    }

    /// Lines that are assistant responses with usage. Scans raw bytes with `memchr`/`memmem`:
    /// session logs reach 1.5 GB and only a fraction of the lines matter, so JSON parsing
    /// happens only on the matches.
    private static func candidateLines(in data: Data) -> [Data] {
        let markers = ["\"type\":\"assistant\"", "\"usage\""].map { Array($0.utf8) }
        var lines: [Data] = []
        data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
            guard var cursor = buffer.baseAddress else { return }
            let end = cursor + buffer.count
            while cursor < end {
                let remaining = end - cursor
                let newline = memchr(cursor, 0x0A, remaining).map { UnsafeRawPointer($0) } ?? end
                let length = newline - cursor
                let matches = markers.allSatisfy { marker in
                    marker.withUnsafeBytes { memmem(cursor, length, $0.baseAddress, marker.count) != nil }
                }
                if matches { lines.append(Data(bytes: cursor, count: length)) }
                cursor = newline + 1
            }
        }
        return lines
    }

    /// Only the fields Orbix needs; everything else in the line (the conversation) is ignored.
    private struct Row: Decodable {
        let type: String?
        let timestamp: String?
        let sessionId: String?
        let requestId: String?
        let uuid: String?
        let message: Message?

        struct Message: Decodable {
            let id: String?
            let model: String?
            let usage: Usage?
        }

        struct Usage: Decodable {
            let input_tokens: Int?
            let output_tokens: Int?
            let cache_creation_input_tokens: Int?
            let cache_read_input_tokens: Int?
            let cache_creation: CacheCreation?
            let speed: String?
        }

        struct CacheCreation: Decodable {
            let ephemeral_1h_input_tokens: Int?
        }
    }
}
