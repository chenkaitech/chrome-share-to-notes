// Draws the extension icons (Notes-style yellow pad with a link arrow).
import AppKit
let out = CommandLine.arguments[1]
for size in [16, 32, 48, 128] {
    let s = CGFloat(size)
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size, bitsPerSample: 8,
                               samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
                               bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let r = NSRect(x: s * 0.06, y: s * 0.06, width: s * 0.88, height: s * 0.88)
    NSColor.white.setFill()
    NSBezierPath(roundedRect: r, xRadius: s * 0.2, yRadius: s * 0.2).fill()
    let top = NSRect(x: r.minX, y: r.maxY - s * 0.26, width: r.width, height: s * 0.26)
    NSColor(red: 1, green: 0.8, blue: 0.1, alpha: 1).setFill()
    let clip = NSBezierPath(roundedRect: r, xRadius: s * 0.2, yRadius: s * 0.2); clip.addClip()
    NSBezierPath(rect: top).fill()
    NSColor(white: 0.35, alpha: 1).setStroke()
    let arrow = NSBezierPath(); arrow.lineWidth = max(1.5, s * 0.08); arrow.lineCapStyle = .round; arrow.lineJoinStyle = .round
    arrow.move(to: NSPoint(x: s * 0.3, y: s * 0.22)); arrow.line(to: NSPoint(x: s * 0.68, y: s * 0.6))
    arrow.move(to: NSPoint(x: s * 0.42, y: s * 0.6)); arrow.line(to: NSPoint(x: s * 0.68, y: s * 0.6)); arrow.line(to: NSPoint(x: s * 0.68, y: s * 0.34))
    arrow.stroke()
    NSGraphicsContext.current = nil
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "\(out)/\(size).png"))
}
