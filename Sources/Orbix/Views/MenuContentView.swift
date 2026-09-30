import SwiftUI

struct MenuContentView: View {
    @Environment(UsageStore.self) private var store
    @Environment(\.colorScheme) private var scheme

    private var t: Theme { Theme.of(scheme) }

    var body: some View {
        VStack(spacing: 0) {
            header
            Hairline(theme: t)

            if store.showingSettings {
                // Taller than a 13" screen allows, so it scrolls past 640 pt.
                ScrollView {
                    SettingsView(theme: t).padding(14)
                }
                .scrollIndicators(.never)
                .frame(height: 640)
            } else if store.panelMode == .compact {
                VStack(spacing: 8) {
                    CompactPanel(store: store, theme: t)
                    if ProfileManager.shared.hasExtraProfiles {
                        ProfilesCard(profiles: ProfileManager.shared, theme: t)
                    }
                }
                .padding(12)
            } else {
                VStack(spacing: 10) {
                    SessionHero(store: store, theme: t)
                    if let error = store.errorMessage {
                        Banner(text: error, color: t.warm, background: t.warmSoft)
                    }
                    if let snapshot = store.snapshot, snapshot.weekly != nil || !snapshot.models.isEmpty {
                        LimitsCard(snapshot: snapshot, theme: t)
                    }
                    if ProfileManager.shared.hasExtraProfiles {
                        ProfilesCard(profiles: ProfileManager.shared, theme: t)
                    }
                    if store.chromeSessionEnabled || store.extras != nil {
                        ExtrasCard(extras: store.extras, error: store.extrasError, theme: t)
                    }
                    if let activity = store.activity {
                        APICostCard(activity: activity, theme: t)
                        ActivityCard(activity: activity, theme: t)
                        ModelsList(activity: activity, theme: t)
                    }
                }
                .padding(14)
            }

            Hairline(theme: t)
            footer
        }
        .frame(width: 340)
        .background(t.bg)
        .foregroundStyle(t.fg)
    }

    private var header: some View {
        HStack(spacing: 9) {
            Group {
                if store.showingSettings {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(t.accent)
                } else {
                    Image(nsImage: OrbixMark.logoImage(points: 22, color: NSColor(pill.color)))
                }
            }
            .frame(width: 22, height: 22)

            VStack(alignment: .leading, spacing: 0) {
                Text(store.showingSettings ? "Ajustes" : "Orbix")
                    .font(Brand.sans(14, .semibold))
                Text(subtitle)
                    .font(Brand.mono(10))
                    .foregroundStyle(t.muted)
                    .lineLimit(1)
            }
            Spacer()
            if !store.showingSettings {
                StatePill(text: pill.text, color: pill.color, background: pill.background)
            }
            IconButton(symbol: store.showingSettings ? "xmark" : "gearshape", theme: t,
                       active: store.showingSettings,
                       help: store.showingSettings ? "Cerrar ajustes" : "Ajustes") {
                store.showingSettings.toggle()
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
    }

    private var subtitle: String {
        if store.showingSettings { return "Claude · \(store.source.label.lowercased())" }
        let profile = ProfileManager.shared.active
        let parts = [profile.isMain ? nil : "perfil \(profile.slug)", store.snapshot?.plan, store.snapshot?.account,
                     store.snapshot?.source].compactMap { $0 }
        return parts.isEmpty ? "Claude" : parts.joined(separator: " · ")
    }

    private var pill: (text: String, color: Color, background: Color) {
        if store.isLoading && store.snapshot == nil { return ("···", t.warm, t.warmSoft) }
        if store.errorMessage != nil { return (store.snapshot == nil ? "ERROR" : "ANTIGUO", t.warm, t.warmSoft) }
        guard let session = store.snapshot?.session else { return ("···", t.muted, t.track) }
        if session.percent >= 90 { return ("LÍMITE", t.danger, t.dangerSoft) }
        return ("OK", t.accent, t.accentSoft)
    }

    private var footer: some View {
        HStack(spacing: 8) {
            HStack(spacing: 5) {
                Circle().fill(store.isLoading ? t.warm : t.accent).frame(width: 6, height: 6)
                if let snapshot = store.snapshot {
                    Text("Actualizado \(snapshot.fetchedAt, style: .relative)")
                        .font(Brand.sans(10.5, .semibold))
                        .foregroundStyle(t.secondary)
                } else {
                    Text("Orbix").font(Brand.sans(10.5, .semibold)).foregroundStyle(t.secondary)
                }
            }
            Spacer()
            if !store.showingSettings {
                IconButton(symbol: store.panelMode == .compact ? "rectangle.expand.vertical" : "rectangle.compress.vertical",
                           theme: t, help: store.panelMode == .compact ? "Vista completa" : "Vista compacta") {
                    store.panelMode = store.panelMode == .compact ? .full : .compact
                }
            }
            IconButton(symbol: "arrow.clockwise", theme: t, help: "Actualizar") { store.refreshNow() }
                .disabled(store.isLoading)
            IconButton(symbol: "power", theme: t, help: "Salir de Orbix") { NSApp.terminate(nil) }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
    }
}

// MARK: - Session hero

/// ModelNap's big power button, reused as the session gauge.
struct SessionHero: View {
    let store: UsageStore
    let theme: Theme
    private var t: Theme { theme }

    private var session: UsageBar? { store.snapshot?.session }
    private var tint: Color { session.map { t.level($0.percent) } ?? t.muted }

    var body: some View {
        Card(theme: t) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(session == nil ? 0.08 : 0.14))
                        .frame(width: 72, height: 72)
                    Circle()
                        .stroke(t.track, lineWidth: 4)
                        .frame(width: 56, height: 56)
                    Circle()
                        .trim(from: 0, to: min(1, (session?.percent ?? 0) / 100))
                        .stroke(tint, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 56, height: 56)
                    if let session {
                        Text("\(Int(session.percent.rounded()))")
                            .font(Brand.mono(17, .semibold))
                            .foregroundStyle(tint)
                            + Text("%").font(Brand.mono(10, .medium)).foregroundStyle(tint)
                    } else if store.isLoading {
                        ProgressView().controlSize(.small)
                    } else {
                        Image(systemName: "questionmark").font(.system(size: 18, weight: .semibold)).foregroundStyle(t.muted)
                    }
                }
                .shadow(color: session != nil ? tint.opacity(0.30) : .clear, radius: 10)
                .animation(.easeInOut(duration: 0.4), value: session?.percent)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: 17, weight: .semibold))
                    Text(detail)
                        .font(Brand.sans(11.5))
                        .foregroundStyle(t.secondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var title: String {
        guard let session else { return store.isLoading ? "Consultando…" : "Sin datos" }
        return "\(Int((100 - session.percent).rounded())) % libre"
    }

    private var detail: String {
        guard let session else { return "Preguntando a Claude Code por tus límites." }
        guard let reset = session.resetsAt else { return "Sesión de 5 horas" }
        return "Sesión de 5 h · se reinicia \(ResetText.describe(reset))"
    }
}

// MARK: - Limits

struct LimitsCard: View {
    let snapshot: UsageSnapshot
    let theme: Theme

    var body: some View {
        Card(theme: theme) {
            VStack(alignment: .leading, spacing: 10) {
                Eyebrow(text: "Límites semanales", theme: theme)
                ForEach(Array(([snapshot.weekly].compactMap { $0 } + snapshot.models).enumerated()), id: \.element.id) { index, bar in
                    if index > 0 { Hairline(theme: theme) }
                    LimitRow(bar: bar, theme: theme)
                }
            }
        }
    }
}

struct LimitRow: View {
    let bar: UsageBar
    let theme: Theme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(bar.title.replacingOccurrences(of: " · semanal", with: ""))
                    .font(Brand.sans(12, .medium))
                Spacer()
                Text("\(Int(bar.percent.rounded())) %")
                    .font(Brand.mono(11.5, .semibold))
                    .foregroundStyle(theme.level(bar.percent))
            }
            Meter(percent: bar.percent, color: theme.level(bar.percent), theme: theme)
            if let reset = bar.resetsAt {
                Text("Se reinicia \(ResetText.describe(reset))")
                    .font(Brand.sans(10.5))
                    .foregroundStyle(theme.muted)
            }
        }
    }
}

enum ResetText {
    static func describe(_ date: Date) -> String {
        let seconds = date.timeIntervalSinceNow
        guard seconds > 0 else { return "ahora" }
        let minutes = Int(seconds / 60)
        let days = minutes / 1440, hours = (minutes % 1440) / 60, mins = minutes % 60
        let span = days > 0 ? "\(days) d \(hours) h" : hours > 0 ? "\(hours) h \(mins) min" : "\(max(mins, 1)) min"
        let when = Calendar.current.isDateInToday(date)
            ? date.formatted(date: .omitted, time: .shortened)
            : date.formatted(.dateTime.weekday(.abbreviated).hour().minute())
        return "en \(span) · \(when)"
    }
}
