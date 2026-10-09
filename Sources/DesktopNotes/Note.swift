import Foundation

enum PaperColor: String, Codable, CaseIterable, Sendable {
    case cream, peach, rose, lavender, blue, sage

    var title: String {
        switch self {
        case .cream: "Ваниль"
        case .peach: "Персик"
        case .rose: "Роза"
        case .lavender: "Лаванда"
        case .blue: "Небо"
        case .sage: "Шалфей"
        }
    }
}

struct Note: Codable, Identifiable, Equatable, Sendable {
    var id = UUID()
    var text = ""
    var color: PaperColor = .cream
    var x: Double = 100
    var y: Double = 200
    var width: Double = 320
    var height: Double = 360
    var isPinned = false
    var isHidden = false
    var isDeleted = false

    var title: String {
        let line = text.split(separator: "\n").first.map(String.init) ?? "Новый листик"
        return String(line.prefix(40))
    }
}
