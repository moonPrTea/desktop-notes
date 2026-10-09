import AppKit

extension PaperColor {
    var ink: NSColor {
        switch self {
        case .cream: NSColor(srgbRed: 0.62, green: 0.43, blue: 0.12, alpha: 1)
        case .peach: NSColor(srgbRed: 0.88, green: 0.36, blue: 0.17, alpha: 1)
        case .rose: NSColor(srgbRed: 0.76, green: 0.27, blue: 0.44, alpha: 1)
        case .lavender: NSColor(srgbRed: 0.49, green: 0.34, blue: 0.77, alpha: 1)
        case .blue: NSColor(srgbRed: 0.27, green: 0.48, blue: 0.73, alpha: 1)
        case .sage: NSColor(srgbRed: 0.39, green: 0.53, blue: 0.29, alpha: 1)
        }
    }

    var paper: NSColor {
        switch self {
        case .cream: NSColor(srgbRed: 0.98, green: 0.94, blue: 0.79, alpha: 1)
        case .peach: NSColor(srgbRed: 1.00, green: 0.88, blue: 0.80, alpha: 1)
        case .rose: NSColor(srgbRed: 0.98, green: 0.85, blue: 0.89, alpha: 1)
        case .lavender: NSColor(srgbRed: 0.90, green: 0.86, blue: 0.98, alpha: 1)
        case .blue: NSColor(srgbRed: 0.83, green: 0.92, blue: 0.98, alpha: 1)
        case .sage: NSColor(srgbRed: 0.88, green: 0.94, blue: 0.81, alpha: 1)
        }
    }
}

final class PaperView: NSView {
    var color: PaperColor = .cream { didSet { needsDisplay = true } }
    var onHide: (() -> Void)?
    private var swipeDistance: CGFloat = 0
    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        let sheet = bounds.insetBy(dx: 12, dy: 16)
        let outline = NSBezierPath(roundedRect: sheet, xRadius: 22, yRadius: 22)
        NSGraphicsContext.saveGraphicsState()
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.20)
        shadow.shadowBlurRadius = 12
        shadow.shadowOffset = NSSize(width: 0, height: -5)
        shadow.set()
        NSColor(calibratedWhite: 0.995, alpha: 1).setFill()
        outline.fill()
        NSGraphicsContext.restoreGraphicsState()

        let inner = NSRect(x: 25, y: 72, width: bounds.width - 50, height: bounds.height - 106)
        let paper = NSBezierPath(roundedRect: inner, xRadius: 15, yRadius: 15)
        let light = color.paper.blended(withFraction: 0.33, of: .white) ?? color.paper
        NSGradient(starting: light, ending: color.paper)?.draw(in: paper, angle: 90)
        color.ink.withAlphaComponent(0.12).setStroke()
        paper.lineWidth = 0.6
        paper.stroke()

        NSGraphicsContext.saveGraphicsState()
        paper.addClip()
        // Deterministic grain: the paper texture stays still while typing.
        for index in 0..<1800 {
            let x = inner.minX + CGFloat((index * 73) % 997) / 997 * inner.width
            let y = inner.minY + CGFloat((index * 137) % 991) / 991 * inner.height
            NSColor.white.withAlphaComponent(0.22).setFill()
            NSRect(x: x, y: y, width: 0.8, height: 0.8).fill()
        }
        NSGraphicsContext.restoreGraphicsState()
        drawPin(at: NSPoint(x: bounds.midX, y: 38))

        let fold = NSBezierPath()
        fold.move(to: NSPoint(x: sheet.maxX - 25, y: sheet.maxY))
        fold.line(to: NSPoint(x: sheet.maxX, y: sheet.maxY - 25))
        fold.curve(to: NSPoint(x: sheet.maxX - 25, y: sheet.maxY),
                   controlPoint1: NSPoint(x: sheet.maxX - 23, y: sheet.maxY - 24),
                   controlPoint2: NSPoint(x: sheet.maxX - 21, y: sheet.maxY - 9))
        NSColor(calibratedWhite: 0.91, alpha: 0.6).setFill()
        fold.fill()
    }

    private func drawPin(at point: NSPoint) {
        NSGraphicsContext.saveGraphicsState()
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 7
        shadow.shadowOffset = NSSize(width: 1, height: -4)
        shadow.shadowColor = color.ink.withAlphaComponent(0.38)
        shadow.set()
        let base = NSBezierPath(ovalIn: NSRect(x: point.x - 14, y: point.y - 5,
                                              width: 28, height: 20))
        color.ink.setFill()
        base.fill()
        NSGraphicsContext.restoreGraphicsState()
        let head = NSBezierPath(ovalIn: NSRect(x: point.x - 11, y: point.y - 15,
                                              width: 22, height: 22))
        let light = color.ink.blended(withFraction: 0.42, of: .white) ?? color.ink
        NSGradient(starting: light, ending: color.ink)?.draw(in: head, angle: 90)
        light.setStroke()
        head.lineWidth = 0.7
        head.stroke()
    }

    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }

    override func swipe(with event: NSEvent) {
        if abs(event.deltaX) > abs(event.deltaY), event.deltaX != 0 { onHide?() }
    }

    override func scrollWheel(with event: NSEvent) {
        if event.phase == .began { swipeDistance = 0 }
        if abs(event.scrollingDeltaX) > abs(event.scrollingDeltaY) {
            swipeDistance += event.scrollingDeltaX
        }
        if event.phase == .ended {
            if abs(swipeDistance) > 90 { onHide?() }
            swipeDistance = 0
        }
        if event.phase == .cancelled { swipeDistance = 0 }
    }
}
