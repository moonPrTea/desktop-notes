import Foundation
import Testing
@testable import DesktopNotes

@MainActor
struct WidgetTests {
    @Test func hiddenNotesRemainAvailableButTrashIsExcluded() {
        var hidden = Note()
        hidden.text = "На рабочем столе"
        hidden.isHidden = true
        var deleted = Note()
        deleted.isDeleted = true
        #expect(WidgetBridge.snapshot([hidden, deleted]) == [WidgetNote(id: hidden.id, text: hidden.text)])
    }

    @Test func publishingIsAtomicAndSkipsUnchangedContent() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = WidgetSnapshotStore(url: directory.appendingPathComponent("widget.json"))
        let note = WidgetNote(id: UUID(), text: "Планы\n\nПрогулка и кофе ☕️")
        #expect(try store.read().isEmpty)
        #expect(try store.write([note]))
        #expect(try store.read() == [note])
        #expect(try !store.write([note]))
        #expect(try store.write([]))
        #expect(try store.read().isEmpty)
    }

    @Test func widgetLinksIdentifyOnlyValidNotes() {
        let note = WidgetNote(id: UUID(), text: "Мысль")
        #expect(WidgetNote.id(from: note.url) == note.id)
        #expect(WidgetNote.id(from: URL(string: "https://note/\(note.id)")!) == nil)
        #expect(WidgetNote.id(from: URL(string: "desktop-notes://other/\(note.id)")!) == nil)
        #expect(WidgetNote.id(from: URL(string: "desktop-notes://note/bad-id")!) == nil)
        #expect(WidgetNote.id(from: URL(string: "desktop-notes://note/extra/\(note.id)")!) == nil)
    }

    @Test func titleAndBodyPreserveUnicodeAndLineBreaks() {
        let note = WidgetNote(id: UUID(), text: "Идеи 💡\n\nПервая\nВторая")
        #expect(note.title == "Идеи 💡")
        #expect(note.body == "Первая\nВторая")
        #expect(WidgetNote(id: UUID(), text: "").title == "Заметка")
        #expect(WidgetNote(id: UUID(), text: "Одна строка").body.isEmpty)
    }

    @Test func snapshotOnlyFollowsSuccessfulSave() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = NoteStore(url: directory.appendingPathComponent("notes.json"))
        var published: [Note] = []
        store.onSave = { published = $0 }
        let note = Note()
        store.add(note)
        #expect(published.isEmpty)
        #expect(store.flush())
        #expect(published == [note])
        let blocked = directory.appendingPathComponent("blocker")
        try Data().write(to: blocked)
        let failing = NoteStore(url: blocked.appendingPathComponent("notes.json"))
        var didPublish = false
        failing.onSave = { _ in didPublish = true }
        failing.add(Note())
        #expect(!failing.flush())
        #expect(!didPublish)
    }
}
