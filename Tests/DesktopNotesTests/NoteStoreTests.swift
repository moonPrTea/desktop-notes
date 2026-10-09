import Foundation
import Testing
@testable import DesktopNotes

@MainActor
struct NoteStoreTests {
    private func temporaryURL() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("notes.json")
    }

    @Test func roundTripPreservesTextAndWindowState() throws {
        let url = temporaryURL()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        let store = NoteStore(url: url)
        var note = Note()
        note.text = "Идеи 🍋\nКупить чай\nВторая строка"
        note.color = .lavender
        note.x = -350
        note.y = 250
        note.width = 440
        note.height = 510
        note.isPinned = true
        store.add(note)
        #expect(store.flush())
        #expect(NoteStore(url: url).notes == [note])
    }

    @Test func hiddenAndDeletedNotesCanBeRestoredAfterRelaunch() throws {
        let url = temporaryURL()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        let store = NoteStore(url: url)
        var note = Note()
        note.text = "Не потерять эту мысль"
        store.add(note)
        note.isHidden = true
        note.isDeleted = true
        store.update(note)
        #expect(store.flush())
        let reopened = NoteStore(url: url)
        var restored = try #require(reopened.note(note.id))
        #expect(restored.isDeleted)
        restored.isHidden = false
        restored.isDeleted = false
        reopened.update(restored)
        #expect(reopened.flush())
        #expect(NoteStore(url: url).notes == [restored])
        #expect(restored.text == note.text)
    }

    @Test func unreadableFileIsNeverOverwritten() throws {
        let url = temporaryURL()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                withIntermediateDirectories: true)
        let original = Data("broken json with recoverable text".utf8)
        try original.write(to: url)
        let store = NoteStore(url: url)
        #expect(store.loadError != nil)
        store.add(Note())
        #expect(!store.flush())
        #expect(try Data(contentsOf: url) == original)
    }

    @Test func failedSaveReportsErrorAndKeepsNotesInMemory() throws {
        let parent = temporaryURL().deletingLastPathComponent()
        defer { try? FileManager.default.removeItem(at: parent) }
        try Data("file blocking a directory".utf8).write(to: parent)
        let store = NoteStore(url: parent.appendingPathComponent("notes.json"))
        var reported = false
        store.onError = { _ in reported = true }
        store.add(Note())
        #expect(!store.flush())
        #expect(reported)
        #expect(store.notes.count == 1)
    }

    @Test func updatingUnknownNoteDoesNotInsertOrReplace() {
        let store = NoteStore(url: temporaryURL())
        store.update(Note())
        #expect(store.notes.isEmpty)
    }
}
