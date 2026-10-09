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

enum NoteResize {
    static func frame(from initial: NSRect, delta: NSPoint, minimum: NSSize,
                      maximum: NSSize, screen: NSRect?) -> NSRect {
        let availableWidth = screen.map { max(1, $0.maxX - initial.minX) } ?? maximum.width
        let availableHeight = screen.map { max(1, initial.maxY - $0.minY) } ?? maximum.height
        let maxWidth = min(maximum.width, availableWidth)
        let maxHeight = min(maximum.height, availableHeight)
        let width = min(max(initial.width + delta.x, min(minimum.width, maxWidth)), maxWidth)
        let height = min(max(initial.height - delta.y, min(minimum.height, maxHeight)), maxHeight)
        return NSRect(x: initial.minX, y: initial.maxY - height, width: width, height: height)
    }
}

final class ResizeHandle: NSView {
    private var initialFrame: NSRect?
    private var initialMouse = NSPoint.zero
    private var screenFrame: NSRect?
    override var isFlipped: Bool { true }
    override var mouseDownCanMoveWindow: Bool { false }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override init(frame: NSRect) {
        super.init(frame: frame)
        toolTip = "Потяни, чтобы изменить размер заметки"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func draw(_ dirtyRect: NSRect) {
        NSColor(calibratedWhite: 0.70, alpha: 1).setStroke()
        for offset in [CGFloat(0), 5] {
            let line = NSBezierPath()
            line.move(to: NSPoint(x: 9 + offset, y: 20))
            line.line(to: NSPoint(x: 20, y: 9 + offset))
            line.lineWidth = 1.4
            line.lineCapStyle = .round
            line.stroke()
        }
    }

    override func resetCursorRects() {
        let image = NSImage(systemSymbolName: "arrow.up.left.and.arrow.down.right",
                            accessibilityDescription: "Изменить размер")!
        image.size = NSSize(width: 16, height: 16)
        addCursorRect(bounds, cursor: NSCursor(image: image, hotSpot: NSPoint(x: 8, y: 8)))
    }

    override func mouseDown(with event: NSEvent) {
        guard let window else { return }
        initialFrame = window.frame
        initialMouse = NSEvent.mouseLocation
        screenFrame = window.screen?.visibleFrame
    }

    override func mouseDragged(with event: NSEvent) {
        guard let window, let initialFrame else { return }
        let mouse = NSEvent.mouseLocation
        let delta = NSPoint(x: mouse.x - initialMouse.x, y: mouse.y - initialMouse.y)
        window.setFrame(NoteResize.frame(from: initialFrame, delta: delta,
                        minimum: window.minSize, maximum: window.maxSize, screen: screenFrame),
                        display: true)
    }

    override func mouseUp(with event: NSEvent) { initialFrame = nil }
}
