import AppKit
import SwiftUI

/// The Settings window: a sidebar with the tabs and the chosen tab on the right. Replaces the
/// in-panel settings, which had grown too long for a 340 pt popover.
@MainActor
enum SettingsWindow {
    private static var window: NSWindow?

    static func show(tab: SettingsTab? = nil) {
        if let tab { UsageStore.shared.settingsTab = tab }
        if window == nil {
            let host = NSHostingView(rootView: SettingsWindowView().environment(UsageStore.shared))
            let created = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 720, height: 560),
                                   styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
                                   backing: .buffered, defer: false)
            created.title = "Ajustes de Orbix"
            created.titlebarAppearsTransparent = true
            created.isReleasedWhenClosed = false
            created.contentView = host
            created.setFrameAutosaveName("OrbixSettings")
            if !created.setFrameUsingName("OrbixSettings") { created.center() }
            window = created
        }
        ProfileManager.shared.reload()
        LoginItem.shared.refresh()
        // A menu bar app is never active on its own; without this the window opens behind others.
        NSApp.activate()
        window?.makeKeyAndOrderFront(nil)
    }
}

struct SettingsWindowView: View {
    @Environment(UsageStore.self) private var store
    @Environment(\.colorScheme) private var scheme
    private var t: Theme { Theme.of(scheme) }

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            Rectangle().fill(t.line).frame(width: 1)
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(store.settingsTab.title)
                        .font(.system(size: 20, weight: .semibold))
                        .padding(.bottom, 2)
                    SettingsView(theme: t, tab: store.settingsTab)
                }
                .frame(maxWidth: 520, alignment: .leading)
                .padding(.horizontal, 28)
                .padding(.top, 44)
                .padding(.bottom, 28)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.automatic)
            .background(t.bg)
        }
        .frame(minWidth: 640, minHeight: 460)
        .foregroundStyle(t.fg)
        .ignoresSafeArea()
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                Image(nsImage: OrbixMark.logoImage(points: 20, color: NSColor(t.accent)))
                Text("Orbix").font(Brand.sans(14, .semibold))
            }
            .padding(.horizontal, 10)
            .padding(.top, 44)
            .padding(.bottom, 14)

            ForEach(SettingsTab.allCases) { tab in
                let selected = tab == store.settingsTab
                Button { store.settingsTab = tab } label: {
                    HStack(spacing: 9) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 12.5, weight: .medium))
                            .frame(width: 18)
                            .foregroundStyle(selected ? t.accent : t.secondary)
                        Text(tab.title)
                            .font(Brand.sans(12.5, selected ? .semibold : .medium))
                            .foregroundStyle(selected ? t.fg : t.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(RoundedRectangle(cornerRadius: 7).fill(selected ? t.accentSoft : .clear))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, 10)
        .frame(width: 180)
        .background(t.card)
    }
}
