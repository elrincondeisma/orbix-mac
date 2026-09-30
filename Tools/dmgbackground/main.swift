import AppKit

// Background of the .dmg window (660×440 pt, rendered @1x and @2x) in Orbix's colours.
// Finder places the icons on top: Orbix at (170, 200) and Aplicaciones at (490, 200),
// measured from the top left; the arrow and texts below are laid out around them.
//   dmgbackground <output-without-extension> <version>

let args = CommandLine.arguments
guard args.count > 2 else {
    FileHandle.standardError.write(Data("uso: dmgbackground <salida-sin-extension> <version>\n".utf8))
    exit(1)
}
let outBase = args[1], version = args[2]

func hex(_ v: UInt32, _ a: CGFloat = 1) -> NSColor {
    NSColor(srgbRed: CGFloat((v >> 16) & 0xFF) / 255, green: CGFloat((v >> 8) & 0xFF) / 255,
            blue: CGFloat(v & 0xFF) / 255, alpha: a)
}

// Light palette: Finder draws the icon labels in dark text.
let W: CGFloat = 660, H: CGFloat = 440
let paper = hex(0xF4F7F5), line = hex(0xDFE8E3), ink = hex(0x0F1614)
let secondary = hex(0x5C6B64), green = hex(0x047857), greenSoft = hex(0xE6F4EE)

/// Draws `string` centred horizontally on `x`, with its top at `top` (top-left coordinates).
func centered(_ string: String, _ font: NSFont, _ color: NSColor, x: CGFloat, top: CGFloat) {
    let text = NSAttributedString(string: string, attributes: [.font: font, .foregroundColor: color])
    let size = text.size()
    text.draw(at: CGPoint(x: x - size.width / 2, y: H - top - size.height))
}

func render(scale: CGFloat) -> Data {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(W * scale), pixelsHigh: Int(H * scale),
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    rep.size = NSSize(width: W, height: H)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    paper.setFill()
    NSRect(x: 0, y: 0, width: W, height: H).fill()

    // Header: small orbit mark + name + one line of instructions.
    let title = NSAttributedString(string: "Orbix", attributes: [.font: NSFont.systemFont(ofSize: 20, weight: .semibold),
                                                                 .foregroundColor: ink])
    let groupWidth = 18 + 8 + title.size().width
    let mark = NSRect(x: W / 2 - groupWidth / 2, y: H - 64, width: 18, height: 18)
    let ring = NSBezierPath(ovalIn: mark.insetBy(dx: 1.5, dy: 1.5))
    ring.lineWidth = 2.2
    green.setStroke()
    ring.stroke()
    green.setFill()
    NSBezierPath(ovalIn: NSRect(x: mark.maxX - 6.5, y: mark.maxY - 6.5, width: 5, height: 5)).fill()
    title.draw(at: CGPoint(x: mark.maxX + 8, y: mark.minY - 4))
    centered("Arrastra Orbix a la carpeta Aplicaciones", .systemFont(ofSize: 13), secondary, x: W / 2, top: 78)

    // Arrow between the two icon slots (icons are centred at y = 200 from the top).
    let y = H - 200
    let arrow = NSBezierPath()
    arrow.move(to: CGPoint(x: 250, y: y))
    arrow.line(to: CGPoint(x: 400, y: y))
    arrow.lineWidth = 3
    arrow.lineCapStyle = .round
    let dash: [CGFloat] = [2, 9]
    arrow.setLineDash(dash, count: 2, phase: 0)
    green.withAlphaComponent(0.55).setStroke()
    arrow.stroke()
    let head = NSBezierPath()
    head.move(to: CGPoint(x: 398, y: y + 10))
    head.line(to: CGPoint(x: 412, y: y))
    head.line(to: CGPoint(x: 398, y: y - 10))
    head.lineWidth = 3
    head.lineCapStyle = .round
    head.lineJoinStyle = .round
    green.setStroke()
    head.stroke()

    // Footer card: what it is + version.
    let footer = NSRect(x: 40, y: 28, width: W - 80, height: 58)
    let card = NSBezierPath(roundedRect: footer, xRadius: 12, yRadius: 12)
    NSColor.white.setFill()
    card.fill()
    line.setStroke()
    card.lineWidth = 1
    card.stroke()
    centered("El uso de tu cuenta de Claude en la barra de menús", .systemFont(ofSize: 12, weight: .medium), ink,
             x: W / 2, top: H - footer.maxY + 12)
    let pill = "versión \(version)"
    let pillText = NSAttributedString(string: pill, attributes: [.font: NSFont.monospacedSystemFont(ofSize: 10.5, weight: .medium),
                                                                 .foregroundColor: green])
    let pillSize = pillText.size()
    let pillRect = NSRect(x: W / 2 - pillSize.width / 2 - 8, y: footer.minY + 9, width: pillSize.width + 16, height: pillSize.height + 4)
    greenSoft.setFill()
    NSBezierPath(roundedRect: pillRect, xRadius: pillRect.height / 2, yRadius: pillRect.height / 2).fill()
    pillText.draw(at: CGPoint(x: pillRect.minX + 8, y: pillRect.minY + 2))

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

try! render(scale: 1).write(to: URL(fileURLWithPath: outBase + ".png"))
try! render(scale: 2).write(to: URL(fileURLWithPath: outBase + "@2x.png"))
