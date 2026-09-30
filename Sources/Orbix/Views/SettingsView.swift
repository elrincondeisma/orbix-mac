import SwiftUI

/// Settings shown inside the panel (the gear swaps them in, as in ModelNap).
/// Only brand controls: native popups and buttons look out of place on the themed cards.
struct SettingsView: View {
    @Environment(UsageStore.self) private var store
    let theme: Theme
    private var t: Theme { theme }

    var body: some View {
        @Bindable var store = store

        VStack(alignment: .leading, spacing: 10) {
            loginSection

            section("Vista") {
                SegmentedChoice(options: [(PanelMode.compact, "Compacta"), (.full, "Completa")],
                                selection: $store.panelMode, theme: t)
                note(store.panelMode == .compact
                     ? "Solo la sesión y los límites semanales. El botón del pie cambia a la completa."
                     : "Añade extras de claude.ai, coste en API, actividad y modelos de Claude Code.")
            }

            profilesSection

            section("Origen de los datos") {
                SegmentedChoice(options: [(.auto, "Auto"), (.claudeCode, "Token"), (.cli, "CLI"), (.manual, "Manual")],
                                selection: $store.source, theme: t)
                note(sourceNote)
            }

            section("Extras de claude.ai") {
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Leer la sesión del navegador").font(Brand.sans(12, .medium))
                        note("Arc, Chrome, Brave, Edge o Vivaldi. Para ver reinicios gratis, saldo prepago y uso extra. macOS pedirá permiso para la clave del navegador: elige Permitir siempre.")
                    }
                    Spacer()
                    BrandSwitch(isOn: $store.chromeSessionEnabled, theme: t)
                }
            }

            section("Credencial manual") {
                ZStack(alignment: .leading) {
                    if store.manualCredential.isEmpty {
                        Text("sessionKey o token sk-ant-oat…")
                            .font(Brand.sans(11.5))
                            .foregroundStyle(t.muted)
                    }
                    SecureField("", text: $store.manualCredential)
                        .textFieldStyle(.plain)
                        .font(Brand.mono(11.5))
                }
                .padding(.horizontal, 9).padding(.vertical, 7)
                .background(RoundedRectangle(cornerRadius: 7).fill(t.bg))
                .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(t.line))
                note("Opcional. Una `sessionKey` pegada aquí sustituye a la del navegador. Se guarda en tu Llavero.")
            }

            section("Actualizar cada") {
                SegmentedChoice(options: [1, 2, 5, 10, 15, 30].map { ($0, "\($0) min") },
                                selection: $store.interval, theme: t)
            }

            updatesSection
            aboutSection

            HStack(spacing: 6) {
                Circle().fill(store.errorMessage == nil ? t.accent : t.warm).frame(width: 6, height: 6)
                Text(store.errorMessage ?? "Conectado vía \(store.snapshot?.source ?? "—")")
                    .font(Brand.sans(10.5)).foregroundStyle(t.secondary).lineLimit(2)
                Spacer()
                SoftButton(title: "Probar", symbol: "arrow.clockwise", theme: t) { store.refreshNow() }
            }
            .padding(.horizontal, 2)
        }
    }

    @ViewBuilder
    private var updatesSection: some View {
        @Bindable var updater = AppUpdater.shared
        section("Actualizaciones") {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Buscar automáticamente").font(Brand.sans(12, .medium))
                    note(updater.isAvailable
                         ? "Orbix \(updater.version). Comprueba una vez al día y se actualiza sola."
                         : "No disponible al ejecutar fuera de Orbix.app.")
                }
                Spacer()
                BrandSwitch(isOn: $updater.automaticallyChecks, theme: t)
                    .disabled(!updater.isAvailable)
            }
            HStack {
                Spacer()
                SoftButton(title: "Buscar ahora", symbol: "arrow.down.circle", theme: t) { updater.checkForUpdates() }
                    .disabled(!updater.isAvailable)
            }
        }
    }

    @ViewBuilder
    private var profilesSection: some View {
        @Bindable var profiles = ProfileManager.shared
        section("Perfiles de Claude Code") {
            note("Cada perfil es una cuenta con su propia carpeta (`~/.claude-perfiles/<nombre>`). El activo es el que usa `claude` al abrirlo.")
            ForEach(profiles.profiles.filter { !$0.isMain }) { profile in
                HStack {
                    Text(profile.name).font(Brand.sans(12, .medium))
                    Chip(text: profile.kind == .token ? "token" : "login", theme: t)
                    Text(profile.slug).font(Brand.mono(10)).foregroundStyle(t.muted)
                    Spacer()
                    IconButton(symbol: "trash", theme: t, help: "Quitar de Orbix (la carpeta se conserva)") {
                        profiles.remove(profile)
                    }
                }
            }
            Hairline(theme: t)
            Text("Nuevo perfil").font(Brand.sans(11, .semibold)).foregroundStyle(t.secondary)
            field("Nombre, p. ej. Trabajo", text: $profiles.newName, secure: false)
            SegmentedChoice(options: [(Profile.Kind.login, "Login"), (.token, "Token de larga duración")],
                            selection: $profiles.newKind, theme: t)
            if profiles.newKind == .token {
                field("sk-ant-oat… (claude setup-token)", text: $profiles.newToken, secure: true)
                note("Se guarda en tu Llavero. Puede que Orbix no pueda leer sus límites: estos tokens solo sirven para usar el modelo.")
            } else {
                note("Al crearlo se abre una Terminal con `claude` en el perfil: escribe `/login` y entra con esa cuenta.")
            }
            HStack(alignment: .center) {
                Text("Compartir historial con Principal").font(Brand.sans(11.5))
                Spacer()
                BrandSwitch(isOn: $profiles.newShareHistory, theme: t)
            }
            HStack {
                Spacer()
                SoftButton(title: "Crear perfil", symbol: "plus", theme: t) { profiles.createProfile() }
            }
            Hairline(theme: t)
            if profiles.shellInstalled {
                note("Terminal lista: `claude` usa el perfil activo · `claude --perfil <nombre>` usa otro solo esa vez · `orbix-perfil <nombre>` lo cambia.")
            } else {
                HStack(alignment: .top, spacing: 10) {
                    note("Para que `claude` en la terminal siga el perfil activo, Orbix añade una línea a tu `~/.zshrc`.")
                    Spacer()
                    SoftButton(title: "Activar", symbol: "apple.terminal", theme: t) { profiles.installShell() }
                }
            }
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Aplicar también a las apps").font(Brand.sans(12, .medium))
                    note("VS Code y otras apps que lanzan Claude Code usarán el perfil activo (las que abras después; no aplica a perfiles de token).")
                }
                Spacer()
                BrandSwitch(isOn: $profiles.applyToApps, theme: t)
            }
            if let message = profiles.message { note(message) }
        }
    }

    private func field(_ placeholder: String, text: Binding<String>, secure: Bool) -> some View {
        ZStack(alignment: .leading) {
            if text.wrappedValue.isEmpty {
                Text(placeholder).font(Brand.sans(11.5)).foregroundStyle(t.muted)
            }
            if secure {
                SecureField("", text: text).textFieldStyle(.plain).font(Brand.mono(11.5))
            } else {
                TextField("", text: text).textFieldStyle(.plain).font(Brand.sans(12))
            }
        }
        .padding(.horizontal, 9).padding(.vertical, 7)
        .background(RoundedRectangle(cornerRadius: 7).fill(t.bg))
        .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(t.line))
    }

    private var loginSection: some View {
        let login = LoginItem.shared
        return section("Inicio") {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Abrir al iniciar sesión").font(Brand.sans(12, .medium))
                    note("Orbix aparece en la barra de menús al encender el Mac. También se gestiona en Ajustes del Sistema → General → Ítems de inicio.")
                }
                Spacer()
                BrandSwitch(isOn: Binding(get: { login.isEnabled || login.needsApproval },
                                          set: { login.setEnabled($0) }), theme: t)
            }
            if login.needsApproval {
                HStack {
                    note("Falta aprobarlo en Ajustes del Sistema.")
                    Spacer()
                    SoftButton(title: "Abrir Ajustes", symbol: "gearshape", theme: t) { login.openSystemSettings() }
                }
            }
            if let error = login.errorMessage { note(error) }
        }
    }

    private var aboutSection: some View {
        section("Acerca de") {
            credit(symbol: "person.fill", title: "Creado por Ismael Catala",
                   detail: "github.com/elrincondeisma", url: "https://github.com/elrincondeisma")
        }
    }

    private func credit(symbol: String, title: String, detail: String, url: String) -> some View {
        Button {
            if let link = URL(string: url) { NSWorkspace.shared.open(link) }
        } label: {
            HStack(spacing: 9) {
                Image(systemName: symbol)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(t.accent)
                    .frame(width: 22, height: 22)
                    .background(RoundedRectangle(cornerRadius: 6).fill(t.accentSoft))
                VStack(alignment: .leading, spacing: 1) {
                    Text(title).font(Brand.sans(12, .medium)).foregroundStyle(t.fg)
                    Text(detail).font(Brand.sans(10.5)).foregroundStyle(t.muted)
                }
                Spacer()
                Image(systemName: "arrow.up.right").font(.system(size: 10, weight: .semibold)).foregroundStyle(t.muted)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(url)
    }

    private var sourceNote: String {
        switch store.source {
        case .auto: "Prueba el token de Claude Code, luego `claude /usage` y, por último, la credencial manual."
        case .claudeCode: "Lee el token OAuth que guarda Claude Code. Da también plan, email y uso extra."
        case .cli: "Ejecuta `claude /usage` sin guardar sesión. No necesita credenciales."
        case .manual: "Usa la cookie `sessionKey` de claude.ai o un token `sk-ant-oat…`."
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        Card(theme: t) {
            VStack(alignment: .leading, spacing: 8) {
                Eyebrow(text: title, theme: t)
                content()
            }
        }
    }

    private func note(_ text: String) -> some View {
        Text(.init(text)).font(Brand.sans(10.5)).foregroundStyle(t.muted)
            .fixedSize(horizontal: false, vertical: true)
    }
}
