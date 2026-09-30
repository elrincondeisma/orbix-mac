import AppKit

/// Orbix's own mark: a ring (the orbit) with a small planet on it. In the menu bar the
/// ring's arc also shows how much of the 5-hour session is used.
enum OrbixMark {
    enum Dot { case none, ok, busy, error }

    static let green = NSColor(srgbRed: 0.204, green: 0.827, blue: 0.600, alpha: 1)   // #34D399
    static let amber = NSColor(srgbRed: 0.851, green: 0.643, blue: 0.255, alpha: 1)   // #D9A441
    static let red = NSColor(srgbRed: 0.878, green: 0.541, blue: 0.494, alpha: 1)     // #E08A7E

    /// Menu bar icon. The drawing handler runs with the menu bar's appearance, so
    /// `labelColor` resolves to black or white as needed.
    static func statusImage(percent: Double?, dot: Dot) -> NSImage {
        let image = NSImage(size: NSSize(width: 20, height: 18), flipped: false) { rect in
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius: CGFloat = 6.8

            let track = NSBezierPath()
            track.appendArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 360)
            track.lineWidth = 1.6
            NSColor.labelColor.withAlphaComponent(percent == nil ? 0.35 : 0.25).setStroke()
            track.stroke()

            if let percent, percent > 0 {
                // Clockwise from 12 o'clock, like a watch.
                let arc = NSBezierPath()
                arc.appendArc(withCenter: center, radius: radius, startAngle: 90,
                              endAngle: 90 - 360 * min(percent, 100) / 100, clockwise: true)
                arc.lineWidth = 2.2
                arc.lineCapStyle = .round
                NSColor.labelColor.setStroke()
                arc.stroke()
            }

            guard dot != .none else { return true }
            let color: NSColor = switch dot {
            case .ok: green
            case .busy: amber
            default: red
            }
            color.setFill()
            NSBezierPath(ovalIn: CGRect(x: center.x + 3.6, y: center.y + 3.6, width: 5.6, height: 5.6)).fill()
            return true
        }
        image.isTemplate = false
        return image
    }

    /// Header logo: full orbit plus planet.
    static func logoImage(points: CGFloat, color: NSColor) -> NSImage {
        NSImage(size: NSSize(width: points, height: points), flipped: false) { rect in
            let inset = points * 0.14
            let ring = NSBezierPath(ovalIn: rect.insetBy(dx: inset, dy: inset))
            ring.lineWidth = points * 0.09
            color.setStroke()
            ring.stroke()

            let r = points * 0.14
            let angle = CGFloat.pi / 4
            let orbit = (points - 2 * inset) / 2
            let p = CGPoint(x: rect.midX + orbit * cos(angle), y: rect.midY + orbit * sin(angle))
            NSColor.clear.setFill()
            color.setFill()
            NSBezierPath(ovalIn: CGRect(x: p.x - r, y: p.y - r, width: 2 * r, height: 2 * r)).fill()
            return true
        }
    }
}
