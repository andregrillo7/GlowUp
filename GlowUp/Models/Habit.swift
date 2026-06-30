import SwiftData
import Foundation

@Model
final class Habit {
    var id: UUID
    var name: String
    var category: HabitCategory
    var frequency: HabitFrequency
    var mediaURL: String?
    var createdAt: Date
    var isActive: Bool
    var logs: [HabitLog]

    init(name: String, category: HabitCategory, frequency: HabitFrequency, mediaURL: String? = nil) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.frequency = frequency
        self.mediaURL = mediaURL
        self.createdAt = Date()
        self.isActive = true
        self.logs = []
    }

    var completedToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return logs.contains { Calendar.current.startOfDay(for: $0.date) == today }
    }

    var consistencyScore: Double {
        guard !logs.isEmpty else { return 0 }
        let last30 = logs.filter { $0.date >= Date().addingTimeInterval(-30 * 86400) }
        let expected = frequency.expectedCount(inDays: 30)
        return min(Double(last30.count) / Double(expected), 1.0)
    }
}

enum HabitCategory: String, Codable, CaseIterable {
    case body = "Body"
    case skin = "Skin"
    case mind = "Mind"
    case intelligence = "Intelligence"
    case hobby = "Hobby"
    case emotional = "Emotional"
    case health = "Health"

    var icon: String {
        switch self {
        case .body: return "figure.walk"
        case .skin: return "sparkles"
        case .mind: return "brain"
        case .intelligence: return "book"
        case .hobby: return "paintbrush"
        case .emotional: return "heart"
        case .health: return "leaf"
        }
    }
}

enum HabitFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case twiceDaily = "Twice Daily"
    case everyOtherDay = "Every Other Day"
    case threePerWeek = "3x / Week"
    case weekly = "Weekly"

    func expectedCount(inDays days: Int) -> Int {
        switch self {
        case .daily: return days
        case .twiceDaily: return days * 2
        case .everyOtherDay: return days / 2
        case .threePerWeek: return (days / 7) * 3
        case .weekly: return days / 7
        }
    }
}
