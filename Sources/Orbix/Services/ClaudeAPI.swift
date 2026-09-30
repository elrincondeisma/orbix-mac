import Foundation

enum ClaudeAPIError: LocalizedError {
    case unauthorized
    case rateLimited
    case cloudflare
    case noOrganization
    case http(Int)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .unauthorized: "Credencial rechazada (401/403). Vuelve a iniciar sesión."
        case .rateLimited: "Anthropic está limitando las peticiones. Espera unos minutos."
        case .cloudflare: "claude.ai ha devuelto un desafío de Cloudflare. Prueba con el token de Claude Code."
        case .noOrganization: "La cuenta no tiene ninguna organización."
        case let .http(code): "Error HTTP \(code)."
        case .invalidResponse: "Respuesta inesperada del servidor."
        }
    }
}

/// OAuth API — the same endpoints Claude Code uses (`api.anthropic.com/api/oauth/*`).
enum ClaudeOAuthAPI {
    private static let base = URL(string: "https://api.anthropic.com/api/oauth")!

    static func usage(token: String) async throws -> UsageResponse {
        let data = try await get(base.appendingPathComponent("usage"), token: token)
        return try JSONDecoder().decode(UsageResponse.self, from: data)
    }

    /// Account email and plan; optional, the usage works without it.
    static func profile(token: String) async -> (email: String?, plan: String?) {
        guard let data = try? await get(base.appendingPathComponent("profile"), token: token),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return (nil, nil) }
        let account = json["account"] as? [String: Any]
        let org = json["organization"] as? [String: Any]
        let email = account?["email_address"] as? String ?? account?["email"] as? String
        var plan: String?
        if account?["has_claude_max"] as? Bool == true { plan = "Max" }
        else if account?["has_claude_pro"] as? Bool == true { plan = "Pro" }
        else if let type = org?["organization_type"] as? String { plan = PlanName.from(type) }
        return (email, plan)
    }

    private static func get(_ url: URL, token: String) async throws -> Data {
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("claude-code/2.1.0", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await URLSession.shared.data(for: request)
        try HTTPCheck.validate(response, data: data)
        return data
    }
}

/// Web API with the `sessionKey` cookie of claude.ai.
enum ClaudeWebAPI {
    private static let base = URL(string: "https://claude.ai/api")!

    static func usage(sessionKey: String) async throws -> (UsageResponse, orgName: String?) {
        let org = try await organization(sessionKey: sessionKey)
        let data = try await get(base.appendingPathComponent("organizations/\(org.id)/usage"), sessionKey: sessionKey)
        return (try JSONDecoder().decode(UsageResponse.self, from: data), org.name)
    }

    /// What claude.ai knows and `claude /usage` does not: saved free resets, prepaid balance
    /// and this month's extra-usage spend. Each piece is best effort.
    static func extras(sessionKey: String) async throws -> WebExtras {
        let org = try await organization(sessionKey: sessionKey)
        let orgURL = base.appendingPathComponent("organizations/\(org.id)")

        // `cedar_ember=1` adds the limit-reset grants to the usage response.
        var usageURL = URLComponents(url: orgURL.appendingPathComponent("usage"), resolvingAgainstBaseURL: false)!
        usageURL.queryItems = [URLQueryItem(name: "cedar_ember", value: "1")]
        async let usage = try? get(usageURL.url!, sessionKey: sessionKey)
        async let prepaid = try? get(orgURL.appendingPathComponent("prepaid/credits"), sessionKey: sessionKey)
        async let overage = try? get(orgURL.appendingPathComponent("overage_spend_limit"), sessionKey: sessionKey)
        let (usageData, prepaidData, overageData) = await (usage, prepaid, overage)

        // Shape only (key names and types, no values) when a reply is not understood.
        if let prepaidData, WebExtras.parsePrepaid(prepaidData) == nil {
            DiagnosticLog.write("web: prepaid shape \(JSONShape.describe(prepaidData))")
        }
        if let overageData, WebExtras.parseOverage(overageData) == nil,
           String(decoding: overageData, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines) != "null" {
            DiagnosticLog.write("web: overage shape \(JSONShape.describe(overageData))")
        }
        return WebExtras(organization: org.name,
                         resets: usageData.flatMap(WebExtras.parseResets) ?? [],
                         prepaid: prepaidData.flatMap(WebExtras.parsePrepaid),
                         overage: overageData.flatMap(WebExtras.parseOverage),
                         fetchedAt: Date())
    }

    private static func organization(sessionKey: String) async throws -> (id: String, name: String?) {
        let orgsData = try await get(base.appendingPathComponent("organizations"), sessionKey: sessionKey)
        guard let orgs = try? JSONSerialization.jsonObject(with: orgsData) as? [[String: Any]] else {
            throw ClaudeAPIError.invalidResponse
        }
        let chosen = orgs.first { ($0["capabilities"] as? [String])?.contains("chat") == true } ?? orgs.first
        guard let org = chosen, let id = org["uuid"] as? String else { throw ClaudeAPIError.noOrganization }
        return (id, org["name"] as? String)
    }

    private static func get(_ url: URL, sessionKey: String) async throws -> Data {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
        request.setValue("sessionKey=\(sessionKey)", forHTTPHeaderField: "Cookie")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await URLSession.shared.data(for: request)
        DiagnosticLog.write("web: \(url.lastPathComponent) HTTP \((response as? HTTPURLResponse)?.statusCode ?? 0)")
        try HTTPCheck.validate(response, data: data)
        return data
    }
}

private enum HTTPCheck {
    static func validate(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else { throw ClaudeAPIError.invalidResponse }
        switch http.statusCode {
        case 200: return
        case 401: throw ClaudeAPIError.unauthorized
        case 403:
            let body = String(decoding: data.prefix(4096), as: UTF8.self)
            if http.value(forHTTPHeaderField: "cf-mitigated") == "challenge" || body.contains("Just a moment") {
                throw ClaudeAPIError.cloudflare
            }
            throw ClaudeAPIError.unauthorized
        case 429: throw ClaudeAPIError.rateLimited
        default: throw ClaudeAPIError.http(http.statusCode)
        }
    }
}

enum PlanName {
    static func from(_ raw: String?) -> String? {
        guard let raw = raw?.lowercased(), !raw.isEmpty else { return nil }
        if raw.contains("max") { return "Max" }
        if raw.contains("pro") { return "Pro" }
        if raw.contains("team") { return "Team" }
        if raw.contains("enterprise") { return "Enterprise" }
        return raw.capitalized
    }
}

/// Describes a JSON value's structure without its contents: `{amount: number, currency: string}`.
enum JSONShape {
    static func describe(_ data: Data) -> String {
        guard let value = try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) else {
            return "not JSON (\(data.count) bytes)"
        }
        return describe(value, depth: 0)
    }

    private static func describe(_ value: Any, depth: Int) -> String {
        switch value {
        case let dict as [String: Any]:
            guard depth < 3 else { return "{…}" }
            let fields = dict.keys.sorted().map { "\($0): \(describe(dict[$0]!, depth: depth + 1))" }
            return "{\(fields.joined(separator: ", "))}"
        case let array as [Any]:
            return "[\(array.count)× \(array.first.map { describe($0, depth: depth + 1) } ?? "empty")]"
        case let number as NSNumber:
            return CFGetTypeID(number) == CFBooleanGetTypeID() ? "bool" : "number"
        case is String: return "string"
        case is NSNull: return "null"
        default: return "?"
        }
    }
}
