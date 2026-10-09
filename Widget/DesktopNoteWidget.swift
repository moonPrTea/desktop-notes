import SwiftUI
import WidgetKit

struct NoteEntry: TimelineEntry {
    let date: Date
    let note: WidgetNote?
    var message = "Создай заметку в Desktop Notes, затем выбери её в настройках виджета."

    static let preview = NoteEntry(date: .now, note: WidgetNote(
        id: UUID(), text: "На сегодня\n\nОдна важная мысль.\nНемного места для нового."))
}

struct NoteProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> NoteEntry { .preview }

    func snapshot(for configuration: SelectNoteIntent, in context: Context) async -> NoteEntry {
        context.isPreview ? .preview : entry(for: configuration)
    }

    func timeline(for configuration: SelectNoteIntent, in context: Context) async -> Timeline<NoteEntry> {
        Timeline(entries: [entry(for: configuration)], policy: .after(.now.addingTimeInterval(900)))
    }

    private func entry(for configuration: SelectNoteIntent) -> NoteEntry {
        do {
            let notes = try WidgetSnapshotStore.configured().read()
            if let selected = configuration.note {
                return NoteEntry(date: .now, note: notes.first { $0.id.uuidString == selected.id },
                                 message: "Эта заметка удалена. Выбери другую через «Изменить виджет».")
            }
            return NoteEntry(date: .now, note: notes.first)
        } catch {
            return NoteEntry(date: .now, note: nil,
                             message: "Открой Desktop Notes, чтобы обновить доступ к заметкам.")
        }
    }
}

struct NoteWidgetView: View {
    let entry: NoteEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let note = entry.note {
                Text(note.title)
                    .font(.system(size: family == .systemSmall ? 17 : 20, weight: .semibold))
                    .foregroundStyle(Color(white: 0.1))
                    .lineLimit(2)
                Text(note.body)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(white: 0.35))
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .clipped()
            } else {
                Text("Desktop Notes").font(.headline).foregroundStyle(Color(white: 0.1))
                Text(entry.message).font(.system(size: 13)).foregroundStyle(Color(white: 0.4))
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(.white, for: .widget)
        .widgetURL(entry.note?.url ?? URL(string: "desktop-notes://new"))
    }
}

@main
struct DesktopNoteWidget: Widget {
    let kind = WidgetSnapshotStore.kind

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectNoteIntent.self, provider: NoteProvider()) { entry in
            NoteWidgetView(entry: entry)
        }
        .configurationDisplayName("Заметка")
        .description("Белый листик с твоей заметкой прямо на рабочем столе.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .containerBackgroundRemovable(false)
    }
}
