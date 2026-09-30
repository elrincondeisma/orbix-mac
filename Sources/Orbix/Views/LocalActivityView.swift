import SwiftUI

/// What local Claude Code usage would have cost on the API.
struct APICostCard: View {
    let activity: LocalActivity
    let theme: Theme
    private var t: Theme { theme }

    var body: some View {
        Card(theme: t) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Eyebrow(text: "Si lo pagaras por API", theme: t)
                    Spacer()
                    Text("precios de lista").font(Brand.sans(10.5)).foregroundStyle(t.muted)
                }
                HStack(alignment: .top) {
                    amount("Sesión actual", activity.costSessionWindow,
                           detail: "desde las \(activity.sessionWindowStart.formatted(date: .omitted, time: .shortened))")
                    Spacer()
                    amount("Últimos 30 días", activity.cost30Days, detail: "solo este Mac")
                }
                if activity.unpricedResponses > 0 {
                    Text("\(activity.unpricedResponses) respuestas sin precio conocido no se incluyen.")
                        .font(Brand.sans(10)).foregroundStyle(t.muted)
                }
            }
        }
    }

    private func amount(_ title: String, _ value: Double, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title).font(Brand.sans(10.5)).foregroundStyle(t.secondary)
            Text(Money.format(value))
                .font(Brand.mono(19, .semibold))
            Text(detail).font(Brand.sans(10)).foregroundStyle(t.muted)
        }
    }
}

/// Tokens today and over the last 7 days, with a small bar chart.
struct ActivityCard: View {
    let activity: LocalActivity
    let theme: Theme
    private var t: Theme { theme }

    var body: some View {
        Card(theme: t) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Eyebrow(text: "Actividad en Claude Code", theme: t)
                    Spacer()
                    Text("7 días").font(Brand.sans(10.5)).foregroundStyle(t.muted)
                }
                WeekChart(days: activity.days, theme: t)

                HStack(spacing: 12) {
                    legend("Hoy", TokenFormat.short(activity.today?.tokens ?? 0), dot: t.accent)
                    legend("7d", TokenFormat.short(activity.week.tokens), dot: t.muted.opacity(0.55))
                    Spacer(minLength: 4)
                    Text("\(activity.week.messages) resp. · \(activity.week.sessions) ses.")
                        .font(Brand.mono(10))
                        .foregroundStyle(t.secondary)
                        .fixedSize()
                }
            }
        }
    }

    private func legend(_ label: String, _ value: String, dot: Color) -> some View {
        HStack(spacing: 4) {
            Circle().fill(dot).frame(width: 6, height: 6)
            Text("\(label) \(value)").font(Brand.mono(10)).foregroundStyle(t.secondary)
        }
        .fixedSize()
    }
}

private struct WeekChart: View {
    let days: [LocalActivity.Day]
    let theme: Theme

    var body: some View {
        let maxTokens = max(days.map(\.tokens).max() ?? 1, 1)
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(days) { day in
                let isToday = Calendar.current.isDateInToday(day.date)
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(isToday
                              ? AnyShapeStyle(LinearGradient(colors: [theme.accent.opacity(0.75), theme.accent],
                                                             startPoint: .bottom, endPoint: .top))
                              : AnyShapeStyle(theme.muted.opacity(0.45)))
                        .frame(width: 18, height: max(3, 40 * CGFloat(day.tokens) / CGFloat(maxTokens)))
                    Text(day.date.formatted(.dateTime.weekday(.narrow)).uppercased())
                        .font(Brand.mono(9, isToday ? .semibold : .regular))
                        .foregroundStyle(isToday ? theme.accent : theme.muted)
                }
                .frame(maxWidth: .infinity)
                .help("\(day.date.formatted(date: .abbreviated, time: .omitted)): \(TokenFormat.short(day.tokens)) tokens · \(Money.format(day.cost)) en API")
            }
        }
        .frame(height: 56, alignment: .bottom)
    }
}

/// Models used in the last 7 days, styled like ModelNap's installed-models list.
struct ModelsList: View {
    let activity: LocalActivity
    let theme: Theme
    private var t: Theme { theme }

    var body: some View {
        if !activity.modelsLast7.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Eyebrow(text: "Modelos usados", theme: t).padding(.horizontal, 2)
                VStack(spacing: 0) {
                    ForEach(Array(activity.modelsLast7.prefix(4).enumerated()), id: \.element.name) { index, model in
                        if index > 0 { Hairline(theme: t) }
                        row(model, isTop: index == 0)
                    }
                }
                .background(RoundedRectangle(cornerRadius: Brand.radius).fill(t.card))
                .overlay(RoundedRectangle(cornerRadius: Brand.radius).strokeBorder(t.line))
            }
        }
    }

    private func row(_ model: LocalActivity.ModelUsage, isTop: Bool) -> some View {
        let share = Double(model.tokens) / Double(max(activity.week.tokens, 1)) * 100
        return HStack(spacing: 9) {
            Circle().fill(isTop ? t.accent : t.line).frame(width: 7, height: 7)
            VStack(alignment: .leading, spacing: 3) {
                Text(ModelName.pretty(model.name))
                    .font(Brand.mono(11.5, isTop ? .semibold : .regular))
                    .lineLimit(1)
                HStack(spacing: 5) {
                    Text("\(TokenFormat.short(model.tokens)) tokens").font(Brand.sans(10.5)).foregroundStyle(t.muted)
                    Chip(text: "\(Money.format(model.cost)) API", theme: t)
                }
            }
            Spacer(minLength: 4)
            Text(share < 1 && share > 0 ? "<1 %" : "\(Int(share.rounded())) %")
                .font(Brand.sans(10.5, .semibold))
                .foregroundStyle(isTop ? t.accent : t.secondary)
                .padding(.horizontal, 7).padding(.vertical, 2)
                .background(Capsule().fill(isTop ? t.accentSoft : t.track))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

enum Money {
    /// `18.22` → `$18,22`; whole dollars from 100 up.
    static func format(_ value: Double) -> String {
        value.formatted(.currency(code: "USD").presentation(.narrow).precision(.fractionLength(value < 100 ? 2 : 0)))
    }
}

enum TokenFormat {
    static func short(_ n: Int) -> String {
        switch n {
        case 1_000_000_000...: String(format: "%.1fB", Double(n) / 1e9)
        case 1_000_000...: String(format: "%.1fM", Double(n) / 1e6)
        case 1_000...: String(format: "%.0fk", Double(n) / 1e3)
        default: "\(n)"
        }
    }
}

enum ModelName {
    /// `claude-opus-5-5` → `Opus 5.5`, `claude-haiku-4-5-20251001` → `Haiku 4.5`.
    static func pretty(_ raw: String) -> String {
        var parts = raw.replacingOccurrences(of: "claude-", with: "").split(separator: "-").map(String.init)
        if let last = parts.last, last.count == 8, Int(last) != nil { parts.removeLast() }
        guard let family = parts.first else { return raw }
        let version = parts.dropFirst().joined(separator: ".")
        return version.isEmpty ? family.capitalized : "\(family.capitalized) \(version)"
    }
}
