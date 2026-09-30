import SwiftUI

/// Visual identity adapted from ModelNap (https://github.com/eriktaveras/modelnap),
/// MIT License, Copyright (c) 2026 Taveras Solutions LLC: emerald on near-black in dark mode,
/// forest green on green-grey in light mode, amber for anything in transition.
/// ModelNap's name and logo are not reused.
struct Theme {
    var bg: Color
    var card: Color
    var line: Color
    var fg: Color
    var secondary: Color
    var muted: Color
    var accent: Color
    var accentSoft: Color
    var warm: Color
    var warmSoft: Color
    var danger: Color
    var dangerSoft: Color
    var track: Color

    static let dark = Theme(
        bg: Color(hex: 0x0B0F0E),
        card: Color(hex: 0x111A16),
        line: Color(hex: 0x22302B),
        fg: Color(hex: 0xE7EFE9),
        secondary: Color(hex: 0x7D938A),
        muted: Color(hex: 0x5C6F66),
        accent: Color(hex: 0x34D399),
        accentSoft: Color(hex: 0x0F2A22),
        warm: Color(hex: 0xD9A441),
        warmSoft: Color(hex: 0x2A2210),
        danger: Color(hex: 0xE08A7E),
        dangerSoft: Color(hex: 0x2E1714),
        track: Color(hex: 0x1A2621)
    )

    static let light = Theme(
        bg: Color(hex: 0xF4F7F5),
        card: Color(hex: 0xFFFFFF),
        line: Color(hex: 0xDFE8E3),
        fg: Color(hex: 0x0F1614),
        secondary: Color(hex: 0x5C6B64),
        muted: Color(hex: 0x8A9992),
        accent: Color(hex: 0x047857),
        accentSoft: Color(hex: 0xE6F4EE),
        warm: Color(hex: 0x8A6212),
        warmSoft: Color(hex: 0xF7EEDB),
        danger: Color(hex: 0xA4402F),
        dangerSoft: Color(hex: 0xF8E6E2),
        track: Color(hex: 0xE4ECE7)
    )

    static func of(_ scheme: ColorScheme) -> Theme { scheme == .dark ? .dark : .light }

    /// Green while there is room, amber past 70 %, red past 90 %.
    func level(_ percent: Double) -> Color {
        switch percent {
        case ..<70: accent
        case ..<90: warm
        default: danger
        }
    }
}

/// System fonts only: SF Pro for text, SF Mono for numbers and identifiers.
enum Brand {
    static let radius: CGFloat = 12

    static func sans(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }

    static func mono(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: opacity)
    }
}
