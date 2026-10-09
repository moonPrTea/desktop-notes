import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    let store = NoteStore()
    var windows: [UUID: NoteWindow] = [:]
    var statusItem: NSStatusItem!
    private var errorPresented = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        installMenus()
        store.onError = { [weak self] error in self?.presentError(error) }
        guard store.loadError == nil else {
            let alert = NSAlert()
            alert.messageText = "Не удалось прочитать листики"
            alert.informativeText = "Файл заметок сохранён без изменений. Закрой приложение и проверь notes.json в ~/Library/Application Support/DesktopNotes."
            alert.runModal()
            NSApp.terminate(nil)
            return
        }
        if store.notes.isEmpty {
            var note = positionedNote()
            note.color = .sage
            note.text = "Место для мыслей\n\nПланы на день, внезапная идея или просто пара тёплых слов.\n\nЭтот листик — твой."
            store.add(note)
        }
        for note in store.notes where !note.isDeleted {
            let window = makeWindow(note)
            if !note.isHidden { window.orderFront(nil) }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(screensChanged),
            name: NSApplication.didChangeScreenParametersNotification, object: nil)
    }

    func makeWindow(_ note: Note) -> NoteWindow {
        if let existing = windows[note.id] { return existing }
        let window = NoteWindow(note: note)
        window.onChange = { [weak self] note in self?.store.update(note) }
        window.onNew = { [weak self] in self?.createNote() }
        windows[note.id] = window
        return window
    }

    func positionedNote() -> Note {
        var note = Note()
        if let screen = NSScreen.main?.visibleFrame {
            let offset = Double(store.notes.filter { !$0.isHidden }.count % 7) * 28
            note.x = screen.midX - note.width / 2 + offset
            note.y = screen.midY - note.height / 2 - offset
        }
        return note
    }

    @objc func createNote() {
        let note = positionedNote()
        store.add(note)
        makeWindow(note).showNote()
    }

    @objc func showAll() {
        for note in store.notes where !note.isDeleted { makeWindow(note).showNote() }
    }

    @objc func hideAll() {
        for window in windows.values where !window.note.isDeleted { window.hideNote() }
    }

    @objc func restoreNote(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? UUID, let note = store.note(id) else { return }
        makeWindow(note).showNote()
    }

    @objc func hideCurrent() { (NSApp.keyWindow as? NoteWindow)?.hideNote() }

    @objc func screensChanged() {
        for window in windows.values { window.ensureVisible() }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if store.loadError != nil { return .terminateNow }
        return store.flush() ? .terminateNow : .terminateCancel
    }

    private func presentError(_ error: Error) {
        guard !errorPresented else { return }
        errorPresented = true
        let alert = NSAlert()
        alert.messageText = "Листики пока не сохранены"
        alert.informativeText = "Не закрывай приложение, пока не появится место или доступ к диску.\n\n" + error.localizedDescription
        alert.runModal()
        errorPresented = false
    }
}
