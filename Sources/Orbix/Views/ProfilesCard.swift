import SwiftUI

/// Claude Code profiles in the panel, one switch each: on is the active profile (the account
/// every new `claude` uses). Turning another on moves the selection; turning the active one
/// off goes back to the main profile.
struct ProfilesCard: View {
    let profiles: ProfileManager
    let theme: Theme
    private var t: Theme { theme }

    var body: some View {
        Card(theme: t) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Eyebrow(text: "Cuentas", theme: t)
                    Spacer()
                    if profiles.busy { ProgressView().controlSize(.mini) }
                }
                .padding(.bottom, 6)
                ForEach(Array(profiles.profiles.enumerated()), id: \.element.id) { index, profile in
                    if index > 0 { Hairline(theme: t) }
                    ProfileRow(profile: profile, profiles: profiles, theme: t)
                }
                if let message = profiles.message {
                    Text(.init(message)).font(Brand.sans(10.5)).foregroundStyle(t.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 6)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: profiles.message)
        }
    }
}

private struct ProfileRow: View {
    let profile: Profile
    let profiles: ProfileManager
    let theme: Theme
    private var t: Theme { theme }
    private var isActive: Bool { profile.slug == profiles.activeSlug }

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(profile.name)
                    .font(Brand.sans(12.5, isActive ? .semibold : .medium))
                    .foregroundStyle(isActive ? t.fg : t.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                detail
            }
            Spacer(minLength: 6)
            IconButton(symbol: "apple.terminal", theme: t, help: "Abrir claude con \(profile.name)") {
                profiles.openClaude(in: profile)
            }
            BrandSwitch(isOn: Binding(
                get: { isActive },
                // Turning the main profile off is a no-op: some profile is always active.
                set: { on in profiles.activate(on ? profile : .main) }
            ), theme: t)
            .help(isActive ? "Cuenta activa" : "Usar \(profile.name) en los próximos claude")
        }
        .padding(.vertical, 7)
    }

    /// `login · sesión 2 % · semana 48 %` or `token · sin límites`.
    private var detail: some View {
        HStack(spacing: 4) {
            Text(profile.kind == .token ? "token" : "login")
            if let snapshot = profiles.usage[profile.slug] {
                if let session = snapshot.session { dot; percent("sesión", session.percent) }
                if let weekly = snapshot.weekly { dot; percent("semana", weekly.percent) }
            } else if profile.kind == .token {
                dot; Text("sin límites").help("Con un token de larga duración Claude Code no informa de los límites.")
            } else if let error = profiles.usageErrors[profile.slug] {
                dot; Text("sin datos").help(error)
            }
        }
        .font(Brand.sans(10.5))
        .foregroundStyle(t.muted)
        .lineLimit(1)
    }

    private var dot: some View { Text("·") }

    private func percent(_ label: String, _ value: Double) -> some View {
        HStack(spacing: 3) {
            Text(label)
            Text("\(Int(value.rounded())) %").font(Brand.mono(10.5, .semibold)).foregroundStyle(t.level(value))
        }
    }
}
