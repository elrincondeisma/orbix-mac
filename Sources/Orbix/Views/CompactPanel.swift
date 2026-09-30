import SwiftUI

/// The short view: session gauge, weekly limits and, when there are any, unused extras.
struct CompactPanel: View {
    let store: UsageStore
    let theme: Theme
    private var t: Theme { theme }

    var body: some View {
        Card(theme: t, padding: 12) {
            VStack(alignment: .leading, spacing: 10) {
                session
                if let error = store.errorMessage {
                    Text(error).font(Brand.sans(10.5)).foregroundStyle(t.warm)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let snapshot = store.snapshot {
                    let bars = [snapshot.weekly].compactMap { $0 } + snapshot.models
                    if !bars.isEmpty { Hairline(theme: t) }
                    ForEach(bars) { CompactLimitRow(bar: $0, theme: t) }
                }
                if let extras = store.extras, !extras.resets.isEmpty {
                    Hairline(theme: t)
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise.circle.fill").foregroundStyle(t.accent)
                        Text(extras.resets.count == 1 ? "1 reinicio gratis" : "\(extras.resets.count) reinicios gratis")
                            .font(Brand.sans(11.5, .medium))
                        Spacer()
                        if let next = extras.resets.first.flatMap({ $0 }) {
                            Text("caduca \(next.formatted(.dateTime.day().month(.abbreviated)))")
                                .font(Brand.sans(10.5)).foregroundStyle(t.muted)
                        }
                    }
                }
            }
        }
    }

    private var session: some View {
        let bar = store.snapshot?.session
        let tint = bar.map { t.level($0.percent) } ?? t.muted
        return HStack(spacing: 12) {
            ZStack {
                Circle().stroke(t.track, lineWidth: 3.5)
                Circle()
                    .trim(from: 0, to: min(1, (bar?.percent ?? 0) / 100))
                    .stroke(tint, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                if let bar {
                    Text("\(Int(bar.percent.rounded()))").font(Brand.mono(13, .semibold)).foregroundStyle(tint)
                } else if store.isLoading {
                    ProgressView().controlSize(.mini)
                }
            }
            .frame(width: 40, height: 40)
            .animation(.easeInOut(duration: 0.4), value: bar?.percent)

            VStack(alignment: .leading, spacing: 1) {
                Text(bar.map { "\(Int((100 - $0.percent).rounded())) % libre" } ?? (store.isLoading ? "Consultando…" : "Sin datos"))
                    .font(.system(size: 15, weight: .semibold))
                Text(bar?.resetsAt.map { "Sesión de 5 h · reinicia \($0.formatted(date: .omitted, time: .shortened))" } ?? "Sesión de 5 h")
                    .font(Brand.sans(10.5)).foregroundStyle(t.secondary)
            }
            Spacer(minLength: 0)
        }
    }
}

private struct CompactLimitRow: View {
    let bar: UsageBar
    let theme: Theme

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(bar.title.replacingOccurrences(of: " · semanal", with: ""))
                    .font(Brand.sans(11.5, .medium))
                if let reset = bar.resetsAt {
                    Text(reset.formatted(.dateTime.weekday(.abbreviated).hour().minute()))
                        .font(Brand.sans(10)).foregroundStyle(theme.muted)
                }
                Spacer()
                Text("\(Int(bar.percent.rounded())) %")
                    .font(Brand.mono(11, .semibold))
                    .foregroundStyle(theme.level(bar.percent))
            }
            Meter(percent: bar.percent, color: theme.level(bar.percent), theme: theme, height: 5)
        }
    }
}
