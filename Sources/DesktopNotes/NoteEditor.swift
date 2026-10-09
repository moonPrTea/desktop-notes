import AppKit

final class NoteEditor: NSTextView {
    func formatText() {
        guard let storage = textStorage else { return }
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4
        let body: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 15),
            .foregroundColor: NSColor(calibratedWhite: 0.25, alpha: 1),
            .paragraphStyle: paragraph
        ]
        storage.beginEditing()
        storage.addAttributes(body, range: NSRange(location: 0, length: storage.length))
        let title = (string as NSString).lineRange(for: NSRange(location: 0, length: 0))
        storage.addAttributes([
            .font: NSFont.systemFont(ofSize: 20, weight: .semibold),
            .foregroundColor: NSColor(calibratedWhite: 0.10, alpha: 1)
        ], range: title)
        storage.endEditing()
        typingAttributes = body
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard string.isEmpty else { return }
        ("Новая заметка" as NSString).draw(
            at: NSPoint(x: textContainerInset.width, y: textContainerInset.height),
            withAttributes: [
                .font: NSFont.systemFont(ofSize: 20, weight: .semibold),
                .foregroundColor: NSColor(calibratedWhite: 0.65, alpha: 1)
            ])
    }
}
