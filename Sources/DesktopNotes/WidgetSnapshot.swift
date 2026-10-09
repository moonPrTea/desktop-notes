import Foundation

struct WidgetNote: Codable, Identifiable, Equatable, Sendable {
    let id: UUID
    let text: String

    var title: String {
        String(text.split(separator: "\n", omittingEmptySubsequences: false).first ?? "")
            .trimmingCharacters(in: .whitespaces).nonempty ?? "Заметка"
    }

    var body: String {
        guard let newline = text.firstIndex(of: "\n") else { return "" }
        return String(text[text.index(after: newline)...]).trimmingCharacters(in: .newlines)
    }

    var url: URL { URL(string: "desktop-notes://note/\(id.uuidString)")! }

    static func id(from url: URL) -> UUID? {
        guard url.scheme == "desktop-notes", url.host == "note",
              url.pathComponents.count == 2 else { return nil }
        return UUID(uuidString: url.lastPathComponent)
    }
}

private extension String {
    var nonempty: String? { isEmpty ? nil : self }
}

struct WidgetSnapshotStore: Sendable {
    static let kind = "DesktopNoteWidget"
    let url: URL

    static func configured(bundle: Bundle = .main) throws -> Self {
        guard let group = bundle.object(forInfoDictionaryKey: "AppGroupIdentifier") as? String,
              !group.isEmpty, !group.contains("$("),
              let container = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: group) else {
            throw StorageError.unavailable
        }
        return Self(url: container.appendingPathComponent("widget-notes.json"))
    }

    func read() throws -> [WidgetNote] {
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        return try JSONDecoder().decode([WidgetNote].self, from: Data(contentsOf: url))
    }

    @discardableResult
    func write(_ notes: [WidgetNote]) throws -> Bool {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(notes)
        // Moving or hiding an app window must not consume widget reloads.
        if let previous = try? Data(contentsOf: url), previous == data { return false }
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
        return true
    }

    enum StorageError: LocalizedError {
        case unavailable
        var errorDescription: String? {
            "Общий контейнер виджетов недоступен. Проверь подпись и App Groups в Xcode."
        }
    }
}
