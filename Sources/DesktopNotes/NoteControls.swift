import AppKit

extension NoteWindow {
    func configureControls() {
        let pin = button("pin", "Поверх окон", #selector(togglePin), x: 31)
        let palette = button("paintpalette", "Цвет листика", #selector(showPalette), x: 62)
        let hide = button("minus", "Смахнуть листик", #selector(hideNote), x: frame.width - 91)
        let more = button("ellipsis", "Действия с листиком", #selector(showActions), x: frame.width - 60)
        hide.autoresizingMask = [.minXMargin]
        more.autoresizingMask = [.minXMargin]
        controls = [pin, palette, hide, more]
        let hint = NSTextField(labelWithString: "потяни за край · смахни по полю")
        hint.font = .systemFont(ofSize: 9, weight: .medium)
        hint.textColor = NSColor(calibratedWhite: 0.52, alpha: 1)
        hint.alignment = .center
        hint.frame = NSRect(x: 32, y: frame.height - 31, width: frame.width - 64, height: 12)
        hint.autoresizingMask = [.width, .minYMargin]
        paper.addSubview(hint)
    }

    private func button(_ symbol: String, _ label: String, _ action: Selector, x: CGFloat) -> NSButton {
        let button = NSButton(image: NSImage(systemSymbolName: symbol,
                                             accessibilityDescription: label)!, target: self, action: action)
        button.frame = NSRect(x: x, y: 35, width: 27, height: 25)
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

    @objc func showPalette(_ sender: NSButton) {
        let menu = NSMenu()
        for (index, color) in PaperColor.allCases.enumerated() {
            let item = NSMenuItem(title: color.title, action: #selector(selectColor), keyEquivalent: "")
            item.target = self
            item.tag = index
            item.state = color == note.color ? .on : .off
            let swatch = NSImage(size: NSSize(width: 14, height: 14))
            swatch.lockFocus()
            color.paper.setFill()
            NSBezierPath(ovalIn: NSRect(x: 0, y: 0, width: 14, height: 14)).fill()
            swatch.unlockFocus()
            item.image = swatch
            menu.addItem(item)
        }
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: sender.bounds.maxY), in: sender)
    }

    @objc private func selectColor(_ sender: NSMenuItem) {
        guard PaperColor.allCases.indices.contains(sender.tag) else { return }
        note.color = PaperColor.allCases[sender.tag]
        applyStyle()
        onChange?(note)
    }

    @objc func showActions(_ sender: NSButton) {
        let menu = NSMenu()
        let actions: [(String, Selector)] = [
            ("Новый листик", #selector(newNote)),
            ("Смахнуть", #selector(hideNote)),
            ("В корзину", #selector(trashNote))
        ]
        for (title, action) in actions {
            let item = menu.addItem(withTitle: title, action: action, keyEquivalent: "")
            item.target = self
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
