import AppKit

final class PaperView: NSView {
    var onHide: (() -> Void)?
    private var swipeDistance: CGFloat = 0
    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        let card = bounds.insetBy(dx: 12, dy: 16)
        let outline = NSBezierPath(roundedRect: card, xRadius: 20, yRadius: 20)
        NSGraphicsContext.saveGraphicsState()
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.10)
        shadow.shadowBlurRadius = 10
        shadow.shadowOffset = NSSize(width: 0, height: -4)
        shadow.set()
        NSColor.white.setFill()
        outline.fill()
        NSGraphicsContext.restoreGraphicsState()
        NSColor(calibratedWhite: 0.88, alpha: 1).setStroke()
        outline.lineWidth = 0.75
        outline.stroke()
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
