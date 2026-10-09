import AppKit
import WidgetKit

@MainActor
final class WidgetBridge {
    private var reload: Task<Void, Never>?
    private var hasReportedError = false

    static func snapshot(_ notes: [Note]) -> [WidgetNote] {
        notes.filter { !$0.isDeleted }.map { WidgetNote(id: $0.id, text: $0.text) }
    }

    func publish(_ notes: [Note]) {
        // The lightweight SwiftPM build intentionally has no widget extension.
        guard Bundle.main.object(forInfoDictionaryKey: "AppGroupIdentifier") != nil else { return }
        do {
            let snapshot = Self.snapshot(notes)
            guard try WidgetSnapshotStore.configured().write(snapshot) else { return }
            reload?.cancel()
            reload = Task {
                do { try await Task.sleep(for: .seconds(2)) }
                catch { return }
                WidgetCenter.shared.reloadTimelines(ofKind: WidgetSnapshotStore.kind)
            }
        } catch {
            guard !hasReportedError else { return }
            hasReportedError = true
            let alert = NSAlert()
            alert.messageText = "Не удалось обновить виджеты"
            alert.informativeText = "Сами заметки сохранены в приложении.\n\n" + error.localizedDescription
            alert.runModal()
        }
    }

    func flushReload() {
        guard Bundle.main.object(forInfoDictionaryKey: "AppGroupIdentifier") != nil else { return }
        reload?.cancel()
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetSnapshotStore.kind)
    }
}
