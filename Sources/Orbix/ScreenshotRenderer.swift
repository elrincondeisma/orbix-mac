#if DEBUG
import AppKit
import SwiftUI

/// `Orbix --render-shots <dir>` renders the panel with the demo data to PNGs for the website:
/// compact and full view, light and dark, at 2×, in the language the process runs in
/// (`-AppleLanguages "(en)"`). Debug builds only.
@MainActor
enum ScreenshotRenderer {
    static func runIfRequested() -> Bool {
        let arguments = CommandLine.arguments
        guard let index = arguments.firstIndex(of: "--render-shots"), index + 1 < arguments.count else { return false }
        let folder = URL(fileURLWithPath: arguments[index + 1], isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        let store = UsageStore.shared
        store.loadDemo()
        ProfileManager.shared.loadDemo()
        for mode in [PanelMode.compact, .full] {
            store.panelMode = mode
            for scheme in [ColorScheme.light, .dark] {
                let view = MenuContentView(staticLayout: true)
                    .environment(store)
                    .environment(\.colorScheme, scheme)
                let name = "panel-\(mode == .compact ? "compacta" : "completa")-\(scheme == .dark ? "oscuro" : "claro").png"
                write(view, to: folder.appendingPathComponent(name))
            }
        }
        // Settings tabs, to review long texts in each language (not used by the website).
        for tab in SettingsTab.allCases {
            let view = VStack(alignment: .leading, spacing: 14) {
                Text(tab.title).font(.system(size: 20, weight: .semibold))
                SettingsView(theme: Theme.of(.dark), tab: tab)
            }
            .frame(width: 520, alignment: .leading)
            .padding(28)
            .background(Theme.of(.dark).bg)
            .foregroundStyle(Theme.of(.dark).fg)
            .environment(store)
            .environment(\.colorScheme, .dark)
            write(view, to: folder.appendingPathComponent("ajustes-\(tab.rawValue).png"))
        }
        return true
    }

    private static func write(_ view: some View, to url: URL) {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        guard let image = renderer.cgImage,
              let png = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:]) else { return }
        try? png.write(to: url)
        print(url.path)
    }
}
#endif
