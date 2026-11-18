import Foundation

/// Claude API list prices (USD per million tokens), to estimate what local usage would have
/// cost if billed through the API. Source: platform.claude.com/docs/en/about-claude/pricing,
/// checked 2026-11-18.
enum APIPricing {
    struct Price {
        let input: Double
        let output: Double
        let cacheRead: Double
        /// Models priced by prompt length (Haiku 5.5): above `threshold` prompt tokens the whole
        /// request is billed at these prices instead.
        var longPrompt: (threshold: Int, price: Tier)? = nil
    }

    struct Tier {
        let input: Double
        let output: Double
        let cacheRead: Double
    }

    private static let table: [String: Price] = [
        "fable-5-2": Price(input: 8, output: 40, cacheRead: 0.20),
        "opus-5-5": Price(input: 4, output: 20, cacheRead: 0.20),
        "opus-5": Price(input: 5, output: 25, cacheRead: 0.50),
        "opus-4-8": Price(input: 5, output: 25, cacheRead: 0.50),
        "opus-4-7": Price(input: 5, output: 25, cacheRead: 0.50),
        "opus-4-6": Price(input: 5, output: 25, cacheRead: 0.50),
        "fable-5-1": Price(input: 10, output: 50, cacheRead: 0.25),
        "fable-5": Price(input: 10, output: 50, cacheRead: 1.00),
        // Cache hits on Opus 5.5 and Sonnet 5.5 are 0.05× input; Fable 5.1 and 5.2, 0.025×.
        "sonnet-5-5": Price(input: 2, output: 10, cacheRead: 0.10),
        "sonnet-5": Price(input: 2, output: 10, cacheRead: 0.20),
        "sonnet-4-6": Price(input: 3, output: 15, cacheRead: 0.30),
        "haiku-5-5": Price(input: 0.10, output: 0.50, cacheRead: 0.01,
                           longPrompt: (100_000, Tier(input: 0.50, output: 2.50, cacheRead: 0.05))),
        "haiku-4-5": Price(input: 1, output: 5, cacheRead: 0.10),
    ]

    /// `claude-haiku-4-5-20251001` → `haiku-4-5`.
    static func price(for model: String) -> Price? {
        var key = model.replacingOccurrences(of: "claude-", with: "")
        if let suffix = key.range(of: #"-\d{8}$"#, options: .regularExpression) { key.removeSubrange(suffix) }
        return table[key]
    }

    /// Cache writes cost 1.25× input (5-minute TTL) or 2× (1-hour TTL); fast mode doubles everything.
    static func cost(model: String, input: Int, output: Int, cacheRead: Int,
                     cacheWrite5m: Int, cacheWrite1h: Int, fast: Bool) -> Double? {
        guard let price = price(for: model) else { return nil }
        // The prompt is everything sent in: fresh input plus what was read from or written to cache.
        let prompt = input + cacheRead + cacheWrite5m + cacheWrite1h
        let p: Tier
        if let long = price.longPrompt, prompt > long.threshold {
            p = long.price
        } else {
            p = Tier(input: price.input, output: price.output, cacheRead: price.cacheRead)
        }
        let base = Double(input) * p.input + Double(output) * p.output + Double(cacheRead) * p.cacheRead
            + Double(cacheWrite5m) * p.input * 1.25 + Double(cacheWrite1h) * p.input * 2
        return base / 1_000_000 * (fast ? 2 : 1)
    }
}
