import AppIntents
import Foundation

struct NoteEntity: AppEntity {
    let id: String
    let title: String
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Заметка"
    static let defaultQuery = NoteQuery()
    var displayRepresentation: DisplayRepresentation { DisplayRepresentation(title: "\(title)") }
}

struct NoteQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [NoteEntity] {
        let notes = try await suggestedEntities()
        return identifiers.compactMap { id in notes.first { $0.id == id } }
    }

    func suggestedEntities() async throws -> [NoteEntity] {
        try WidgetSnapshotStore.configured().read().map {
            NoteEntity(id: $0.id.uuidString, title: $0.title)
        }
    }

    func defaultResult() async -> NoteEntity? { try? await suggestedEntities().first }
}

struct SelectNoteIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Выбрать заметку"
    static let description = IntentDescription("Выбери заметку для этого виджета.")

    @Parameter(title: "Заметка")
    var note: NoteEntity?
}
