import AppKit

final class NoteWindow: NSPanel, NSWindowDelegate, NSTextViewDelegate {
    var note: Note
    var onChange: ((Note) -> Void)?
    var onNew: (() -> Void)?
    let paper = PaperView()
    let editor = NSTextView()
    let scroll = NSScrollView()
    var controls: [NSButton] = []
    private var ready = false
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    init(note: Note) {
        self.note = note
        let frame = NSRect(x: note.x, y: note.y, width: note.width, height: note.height)
        super.init(contentRect: frame, styleMask: [.borderless, .resizable],
                   backing: .buffered, defer: false)
        isReleasedWhenClosed = false
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        hidesOnDeactivate = false
        isFloatingPanel = false
        minSize = NSSize(width: 280, height: 280)
        maxSize = NSSize(width: 700, height: 850)
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        appearance = NSAppearance(named: .aqua)
        title = note.title
        delegate = self
        paper.frame = NSRect(origin: .zero, size: frame.size)
        paper.autoresizingMask = [.width, .height]
        contentView = paper
        paper.onHide = { [weak self] in self?.hideNote() }
        configureEditor()
        configureControls()
        applyStyle()
        ensureVisible()
        ready = true
    }

    private func configureEditor() {
        scroll.frame = NSRect(x: 39, y: 89, width: frame.width - 78, height: frame.height - 148)
        scroll.autoresizingMask = [.width, .height]
        scroll.drawsBackground = false
        scroll.hasVerticalScroller = true
        scroll.scrollerStyle = .overlay
        scroll.borderType = .noBorder
        editor.frame = NSRect(origin: .zero, size: scroll.contentSize)
        editor.minSize = NSSize(width: 0, height: scroll.contentSize.height)
        editor.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        editor.isVerticallyResizable = true
        editor.isHorizontallyResizable = false
        editor.autoresizingMask = [.width]
        editor.textContainer?.widthTracksTextView = true
        editor.textContainer?.containerSize = NSSize(width: scroll.contentSize.width,
                                                     height: CGFloat.greatestFiniteMagnitude)
        editor.textContainerInset = NSSize(width: 0, height: 6)
        editor.textContainer?.lineFragmentPadding = 0
        editor.drawsBackground = false
        editor.isRichText = false
        editor.allowsUndo = true
        editor.isAutomaticQuoteSubstitutionEnabled = true
        editor.isAutomaticSpellingCorrectionEnabled = false
        editor.font = NSFont(name: "Avenir Next", size: 19) ?? .systemFont(ofSize: 19)
        editor.textColor = NSColor(srgbRed: 0.22, green: 0.22, blue: 0.23, alpha: 1)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 5
        editor.defaultParagraphStyle = paragraph
        editor.string = note.text
        editor.delegate = self
        editor.setAccessibilityLabel("Текст листика")
        scroll.documentView = editor
        paper.addSubview(scroll)
    }

    func applyStyle() {
        paper.color = note.color
        editor.insertionPointColor = note.color.ink
        // Desktop level keeps paper below regular application windows.
        level = note.isPinned ? .floating : NSWindow.Level(
            rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) + 1)
        for control in controls { control.contentTintColor = note.color.ink }
        controls.first?.image = NSImage(systemSymbolName: note.isPinned ? "pin.fill" : "pin",
                                        accessibilityDescription: "Поверх окон")
    }

    func ensureVisible() {
        let screens = NSScreen.screens.map(\.visibleFrame)
        guard let screen = screens.first(where: { $0.intersects(frame) }) ?? screens.first else { return }
        var adjusted = frame
        adjusted.size.width = min(max(adjusted.width, minSize.width), screen.width)
        adjusted.size.height = min(max(adjusted.height, minSize.height), screen.height)
        adjusted.origin.x = min(max(adjusted.minX, screen.minX), screen.maxX - adjusted.width)
        adjusted.origin.y = min(max(adjusted.minY, screen.minY), screen.maxY - adjusted.height)
        setFrame(adjusted, display: true)
    }

    func textDidChange(_ notification: Notification) {
        note.text = editor.string
        title = note.title
        onChange?(note)
    }

    func windowDidMove(_ notification: Notification) { saveFrame() }
    func windowDidResize(_ notification: Notification) { saveFrame() }

    private func saveFrame() {
        guard ready else { return }
        note.x = frame.minX
        note.y = frame.minY
        note.width = frame.width
        note.height = frame.height
        onChange?(note)
    }

    func showNote() {
        note.isHidden = false
        note.isDeleted = false
        alphaValue = 1
        ensureVisible()
        makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        makeFirstResponder(editor)
        onChange?(note)
    }
}
