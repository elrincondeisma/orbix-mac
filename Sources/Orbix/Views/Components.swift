import SwiftUI

/// White (or near-black) rounded card with a hairline border.
struct Card<Content: View>: View {
    let theme: Theme
    var padding: CGFloat = 12
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: Brand.radius).fill(theme.card))
            .overlay(RoundedRectangle(cornerRadius: Brand.radius).strokeBorder(theme.line))
    }
}

/// Small semibold section label.
struct Eyebrow: View {
    let text: String
    let theme: Theme
    var color: Color?

    var body: some View {
        Text(text)
            .font(Brand.sans(11, .semibold))
            .foregroundStyle(color ?? theme.secondary)
    }
}

struct Hairline: View {
    let theme: Theme
    var body: some View { Rectangle().fill(theme.line).frame(height: 1) }
}

/// Status capsule in the header: dot + short word.
struct StatePill: View {
    let text: String
    let color: Color
    let background: Color

    var body: some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(text).font(Brand.sans(10.5, .semibold))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8).padding(.vertical, 3)
        .background(Capsule().fill(background))
    }
}

struct Chip: View {
    let text: String
    let theme: Theme

    var body: some View {
        Text(text)
            .font(Brand.sans(9.5, .medium))
            .foregroundStyle(theme.secondary)
            .padding(.horizontal, 6).padding(.vertical, 1)
            .background(Capsule().fill(theme.track))
    }
}

/// Capsule bar with a soft gradient, like ModelNap's memory bar.
struct Meter: View {
    let percent: Double
    let color: Color
    let theme: Theme
    var height: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            let fraction = min(1, max(0, percent / 100))
            ZStack(alignment: .leading) {
                Capsule().fill(theme.track)
                Capsule()
                    .fill(LinearGradient(colors: [color.opacity(0.75), color], startPoint: .leading, endPoint: .trailing))
                    .frame(width: fraction > 0 ? max(height, geo.size.width * fraction) : 0)
            }
            .clipShape(Capsule())
        }
        .frame(height: height)
        .animation(.easeInOut(duration: 0.4), value: percent)
    }
}

/// Amber (or red) notice card.
struct Banner: View {
    let text: String
    let color: Color
    let background: Color

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 11))
            Text(text)
                .font(Brand.sans(11))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .foregroundStyle(color)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: Brand.radius).fill(background))
    }
}

/// Borderless icon button used in the header and footer.
struct IconButton: View {
    let symbol: String
    let theme: Theme
    var active = false
    let help: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .medium))
                .frame(width: 26, height: 24)
                .background(RoundedRectangle(cornerRadius: 6).fill(active ? theme.track : .clear))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(theme.secondary)
        .help(help)
    }
}

/// Brand segmented control: the selected option sits on a card-coloured capsule.
struct SegmentedChoice<Value: Hashable>: View {
    let options: [(value: Value, label: String)]
    @Binding var selection: Value
    let theme: Theme

    var body: some View {
        HStack(spacing: 2) {
            ForEach(options, id: \.value) { option in
                let selected = option.value == selection
                Button { selection = option.value } label: {
                    Text(option.label)
                        .font(Brand.sans(11, selected ? .semibold : .medium))
                        .foregroundStyle(selected ? theme.accent : theme.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selected ? theme.card : .clear)
                                .shadow(color: .black.opacity(selected ? 0.08 : 0), radius: 1, y: 1)
                        )
                        .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(selected ? theme.line : .clear))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(2)
        .background(RoundedRectangle(cornerRadius: 8).fill(theme.track))
        .animation(.easeInOut(duration: 0.15), value: selection)
    }
}

/// Soft accent button (accent text on accentSoft).
struct SoftButton: View {
    let title: String
    let symbol: String?
    let theme: Theme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let symbol { Image(systemName: symbol).font(.system(size: 10.5, weight: .semibold)) }
                Text(title).font(Brand.sans(11, .semibold))
            }
            .foregroundStyle(theme.accent)
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(Capsule().fill(theme.accentSoft))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

/// Flat switch in brand colours (ModelNap's BrandSwitch), without the system glow.
struct BrandSwitch: View {
    @Binding var isOn: Bool
    let theme: Theme

    var body: some View {
        Button { isOn.toggle() } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule()
                    .fill(isOn ? theme.accent : theme.track)
                    .overlay(Capsule().strokeBorder(isOn ? theme.accent : theme.line))
                    .frame(width: 36, height: 20)
                Circle()
                    .fill(isOn ? theme.card : theme.muted)
                    .frame(width: 14, height: 14)
                    .padding(.horizontal, 3)
            }
            .animation(.easeInOut(duration: 0.15), value: isOn)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
