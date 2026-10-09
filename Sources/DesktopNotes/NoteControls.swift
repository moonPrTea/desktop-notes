import AppKit

extension NoteWindow {
    func configureControls() {
        let more = button("ellipsis", "Действия с листиком", #selector(showActions), x: frame.width - 56)
        more.autoresizingMask = [.minXMargin]
        controls = [more]
    }

    private func button(_ symbol: String, _ label: String, _ action: Selector, x: CGFloat) -> NSButton {
        let button = NSButton(image: NSImage(systemSymbolName: symbol,
                                             accessibilityDescription: label)!, target: self, action: action)
        button.frame = NSRect(x: x, y: 27, width: 28, height: 24)
        button.isBordered = false
        button.bezelStyle = .inline
        button.imageScaling = .scaleProportionallyDown
        button.toolTip = label
        button.setAccessibilityLabel(label)
        paper.addSubview(button)
        return button
    }

    @objc func togglePin() {
        note.isPinned.toggle()
        applyStyle()
        onChange?(note)
    }

    @objc func showActions(_ sender: NSButton) {
        let menu = NSMenu()
        let actions: [(String, Selector)] = [
            ("Новый листик", #selector(newNote)),
            ("Поверх окон", #selector(togglePin)),
            ("Скрыть", #selector(hideNote)),
            ("В корзину", #selector(trashNote))
        ]
        for (title, action) in actions {
            let item = menu.addItem(withTitle: title, action: action, keyEquivalent: "")
            item.target = self
            if action == #selector(togglePin) { item.state = note.isPinned ? .on : .off }
        }
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: sender.bounds.maxY), in: sender)
    }

    @objc private func newNote() { onNew?() }

    @objc func hideNote() {
        guard !note.isHidden else { return }
        note.isHidden = true
        onChange?(note)
        let original = frame
        NSAnimationContext.runAnimationGroup { context in
            context.duration = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion ? 0 : 0.18
            animator().alphaValue = 0
        } completionHandler: { [weak self] in
            MainActor.assumeIsolated {
                guard let self, self.note.isHidden else { return }
                self.orderOut(nil)
                self.setFrame(original, display: false)
                self.alphaValue = 1
            }
        }
    }

    @objc private func trashNote() {
        note.isDeleted = true
        note.isHidden = true
        onChange?(note)
        orderOut(nil)
    }
}
