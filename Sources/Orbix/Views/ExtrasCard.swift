import SwiftUI

/// What is left to use beyond the normal limits: saved free resets, prepaid balance and
/// the room left in this month's extra-usage cap. Data comes from the claude.ai session.
struct ExtrasCard: View {
    let extras: WebExtras?
    let error: String?
    let theme: Theme
    private var t: Theme { theme }

    var body: some View {
        Card(theme: t) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Eyebrow(text: "Extra sin usar", theme: t)
                    Spacer()
                    Text("claude.ai").font(Brand.sans(10.5)).foregroundStyle(t.muted)
                }
                if let extras {
                    resets(extras.resets)
                    if let prepaid = extras.prepaid {
                        Hairline(theme: t)
                        line("Saldo prepago", value: format(prepaid.amount, prepaid.currency),
                             detail: prepaid.amount > 0 ? "créditos cargados sin gastar" : "no tienes créditos cargados",
                             dimmed: prepaid.amount == 0)
                    }
                    Hairline(theme: t)
                    if let overage = extras.overage {
                        overageRow(overage)
                    } else {
                        line("Uso extra del mes", value: "—", detail: "desactivado en tu cuenta", dimmed: true)
                    }
                } else if let error {
                    Text(error).font(Brand.sans(11)).foregroundStyle(t.warm)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    ProgressView().controlSize(.small)
                }
            }
        }
    }

    @ViewBuilder
    private func resets(_ expirations: [Date?]) -> some View {
        if expirations.isEmpty {
            line("Reinicios gratis", value: "0", detail: "no tienes reinicios guardados")
        } else {
            let next = expirations.first.flatMap { $0 }
            line("Reinicios gratis", value: "\(expirations.count)",
                 detail: next.map { "el próximo caduca \(ResetText.describe($0))" } ?? "sin caducidad",
                 highlight: true)
        }
    }

    private func overageRow(_ overage: WebExtras.Overage) -> some View {
        let currency = overage.used.currency
        let percent = overage.limit > 0 ? overage.used.amount / overage.limit * 100 : 0
        return VStack(alignment: .leading, spacing: 6) {
            line("Uso extra del mes", value: format(overage.remaining, currency),
                 detail: "libres de \(format(overage.limit, currency)) · gastado \(format(overage.used.amount, currency))")
            Meter(percent: percent, color: t.level(percent), theme: t, height: 6)
        }
    }

    private func line(_ title: String, value: String, detail: String,
                      highlight: Bool = false, dimmed: Bool = false) -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(Brand.sans(12, .medium))
                Text(detail).font(Brand.sans(10.5)).foregroundStyle(t.muted)
            }
            Spacer()
            Text(value)
                .font(Brand.mono(15, .semibold))
                .foregroundStyle(highlight ? t.accent : dimmed ? t.muted : t.fg)
        }
    }

    private func format(_ amount: Double, _ currency: String) -> String {
        amount.formatted(.currency(code: currency).presentation(.narrow))
    }
}
