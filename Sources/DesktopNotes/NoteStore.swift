import Foundation

@MainActor
final class NoteStore {
    private(set) var notes: [Note] = []
    private let url: URL
    private var pendingSave: Task<Void, Never>?
    var onError: ((Error) -> Void)?
    private(set) var loadError: Error?

    init(url: URL? = nil) {
        let support = FileManager.default.urls(for: .applicationSupportDirectory,
                                               in: .userDomainMask)[0]
        self.url = url ?? support.appendingPathComponent("DesktopNotes/notes.json")
        do {
            if FileManager.default.fileExists(atPath: self.url.path) {
                notes = try JSONDecoder().decode([Note].self, from: Data(contentsOf: self.url))
            }
        } catch {
            loadError = error
        }
    }

    func add(_ note: Note) {
        notes.append(note)
        scheduleSave()
    }

    func update(_ note: Note) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[index] = note
        scheduleSave()
    }

    func note(_ id: UUID) -> Note? { notes.first { $0.id == id } }

    @discardableResult
    func flush() -> Bool {
        pendingSave?.cancel()
        // Never overwrite an unreadable original with an empty collection.
        guard loadError == nil else { return false }
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            try encoder.encode(notes).write(to: url, options: .atomic)
            return true
        } catch {
            onError?(error)
            return false
        }
    }

    private func scheduleSave() {
        pendingSave?.cancel()
        pendingSave = Task { [weak self] in
            do { try await Task.sleep(for: .milliseconds(350)) }
            catch { return }
            self?.flush()
        }
    }
}
