import Foundation

/// Response of `GET https://api.anthropic.com/api/oauth/usage` and of
/// `GET https://claude.ai/api/organizations/{id}/usage` — both share the same shape.
struct UsageResponse: Decodable, Sendable {
    let fiveHour: UsageWindow?
    let sevenDay: UsageWindow?
    let sevenDayOpus: UsageWindow?
    let sevenDaySonnet: UsageWindow?
    let extraUsage: ExtraUsage?
    let limits: [LimitEntry]?

    enum CodingKeys: String, CodingKey {
        case fiveHour = "five_hour"
        case sevenDay = "seven_day"
        case sevenDayOpus = "seven_day_opus"
        case sevenDaySonnet = "seven_day_sonnet"
        case extraUsage = "extra_usage"
        case limits
    }

    // Tolerant decoding: an unexpected shape in one field must not break the others.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        fiveHour = try? c.decodeIfPresent(UsageWindow.self, forKey: .fiveHour)
        sevenDay = try? c.decodeIfPresent(UsageWindow.self, forKey: .sevenDay)
        sevenDayOpus = try? c.decodeIfPresent(UsageWindow.self, forKey: .sevenDayOpus)
        sevenDaySonnet = try? c.decodeIfPresent(UsageWindow.self, forKey: .sevenDaySonnet)
        extraUsage = try? c.decodeIfPresent(ExtraUsage.self, forKey: .extraUsage)
        limits = try? c.decodeIfPresent([LimitEntry].self, forKey: .limits)
    }
}

struct UsageWindow: Decodable, Sendable {
    let utilization: Double?
    let resetsAt: String?

    enum CodingKeys: String, CodingKey {
        case utilization
        case resetsAt = "resets_at"
    }
}

/// Newer `limits` array; `weekly_scoped` entries name the model they apply to.
struct LimitEntry: Decodable, Sendable {
    let kind: String?
    let percent: Double?
    let resetsAt: String?
    let scope: Scope?

    struct Scope: Decodable, Sendable {
        let model: Model?
    }

    struct Model: Decodable, Sendable {
        let displayName: String?
        enum CodingKeys: String, CodingKey { case displayName = "display_name" }
    }

    enum CodingKeys: String, CodingKey {
        case kind, percent, scope
        case resetsAt = "resets_at"
    }
}

struct ExtraUsage: Decodable, Sendable {
    let isEnabled: Bool?
    let monthlyLimit: Double?
    let usedCredits: Double?
    let currency: String?

    enum CodingKeys: String, CodingKey {
        case isEnabled = "is_enabled"
        case monthlyLimit = "monthly_limit"
        case usedCredits = "used_credits"
        case currency
    }
}

// MARK: - What the UI shows

struct UsageBar: Identifiable, Sendable {
    let id: String
    let title: String
    let percent: Double
    let resetsAt: Date?
}

struct UsageSnapshot: Sendable {
    var session: UsageBar?
    var weekly: UsageBar?
    var models: [UsageBar]
    var extra: ExtraUsage?
    var account: String?
    var plan: String?
    var source: String
    var fetchedAt: Date

    init(session: UsageBar?, weekly: UsageBar?, models: [UsageBar], source: String) {
        self.session = session
        self.weekly = weekly
        self.models = models
        self.source = source
        fetchedAt = Date()
    }

    init(response r: UsageResponse, account: String?, plan: String?, source: String) {
        session = Self.bar("session", "Sesión (5 h)", r.fiveHour)
        weekly = Self.bar("weekly", "Semanal", r.sevenDay)

        var models: [UsageBar] = []
        let scoped = (r.limits ?? []).filter { $0.kind == "weekly_scoped" }
        for entry in scoped {
            guard let name = entry.scope?.model?.displayName, let pct = entry.percent,
                  name.localizedCaseInsensitiveCompare("All models") != .orderedSame else { continue }
            models.append(UsageBar(id: "model-\(name)", title: "\(name) · semanal",
                                   percent: pct, resetsAt: ISO8601.parse(entry.resetsAt)))
        }
        if models.isEmpty {
            if let b = Self.bar("opus", "Opus · semanal", r.sevenDayOpus) { models.append(b) }
            if let b = Self.bar("sonnet", "Sonnet · semanal", r.sevenDaySonnet) { models.append(b) }
        }
        self.models = models
        extra = (r.extraUsage?.isEnabled == true) ? r.extraUsage : nil
        self.account = account
        self.plan = plan
        self.source = source
        fetchedAt = Date()
    }

    private static func bar(_ id: String, _ title: String, _ w: UsageWindow?) -> UsageBar? {
        guard let w, let pct = w.utilization else { return nil }
        return UsageBar(id: id, title: title, percent: pct, resetsAt: ISO8601.parse(w.resetsAt))
    }
}

enum ISO8601 {
    // Built once: the local scanner parses tens of thousands of timestamps per pass.
    private static let withFraction = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
    private static let plain = Date.ISO8601FormatStyle()

    static func parse(_ s: String?) -> Date? {
        guard let s else { return nil }
        return (try? withFraction.parse(s)) ?? (try? plain.parse(s))
    }
}

// MARK: - claude.ai extras

/// Unused extras only claude.ai reports (read with the browser session).
struct WebExtras: Sendable {
    struct Money: Sendable {
        let amount: Double      // in currency units, not cents
        let currency: String
    }

    struct Overage: Sendable {
        let used: Money
        let limit: Double
        var remaining: Double { max(0, limit - used.amount) }
    }

    let organization: String?
    /// Expiry of each free limit reset still available (nil = no expiry), soonest first.
    let resets: [Date?]
    let prepaid: Money?
    let overage: Overage?
    let fetchedAt: Date

    /// `cedar_ember` block: grants that are eligible, not paused, started and not expired.
    /// Same rules as CodexBar; `usable_now` is ignored so a saved reset still counts while gated.
    static func parseResets(_ data: Data) -> [Date?]? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let block = json["cedar_ember"] as? [String: Any],
              block["eligible"] as? Bool == true,
              let grants = block["grants"] as? [[String: Any]], grants.count <= 200 else { return nil }
        let now = Date()
        var expirations: [Date?] = []
        for grant in grants {
            guard let left = grant["resets_left"] as? Int, left > 0, left <= 50,
                  grant["paused"] as? Bool == false else { continue }
            if let start = ISO8601.parse(grant["starts_at"] as? String), start > now { continue }
            let end = ISO8601.parse(grant["ends_at"] as? String)
            if let end, end <= now { continue }
            expirations += Array(repeating: end, count: left)
        }
        return expirations.sorted { ($0 ?? .distantFuture) < ($1 ?? .distantFuture) }
    }

    /// `prepaid/credits`: `{ amount, currency }` in cents. Accounts that never bought credits
    /// get `currency: null`, so dollars are assumed.
    static func parsePrepaid(_ data: Data) -> Money? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let amount = (json["amount"] as? NSNumber)?.doubleValue, amount >= 0 else { return nil }
        let currency = (json["currency"] as? String).flatMap { $0.isEmpty ? nil : $0.uppercased() } ?? "USD"
        return Money(amount: amount / 100, currency: currency)
    }

    /// `overage_spend_limit`: monthly extra-usage spend and cap, in cents.
    static func parseOverage(_ data: Data) -> Overage? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              json["is_enabled"] as? Bool == true,
              let used = (json["used_credits"] as? NSNumber)?.doubleValue,
              let limit = (json["monthly_credit_limit"] as? NSNumber)?.doubleValue,
              let currency = json["currency"] as? String else { return nil }
        return Overage(used: Money(amount: used / 100, currency: currency.uppercased()), limit: limit / 100)
    }
}
