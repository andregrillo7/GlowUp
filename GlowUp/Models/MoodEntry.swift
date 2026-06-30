import SwiftData
import Foundation

@Model
final class MoodEntry {
    var id: UUID
    var date: Date
    var mood: MoodLevel
    var energy: EnergyLevel
    var note: String?

    init(mood: MoodLevel, energy: EnergyLevel, note: String? = nil) {
        self.id = UUID()
        self.date = Date()
        self.mood = mood
        self.energy = energy
        self.note = note
    }
}

enum MoodLevel: Int, Codable, CaseIterable {
    case low = 1, okay = 2, good = 3, great = 4, amazing = 5

    var label: String {
        switch self {
        case .low: return "Low"
        case .okay: return "Okay"
        case .good: return "Good"
        case .great: return "Great"
        case .amazing: return "Amazing"
        }
    }

    var emoji: String {
        switch self {
        case .low: return "🌧"
        case .okay: return "🌤"
        case .good: return "☀️"
        case .great: return "✨"
        case .amazing: return "🌟"
        }
    }
}

enum EnergyLevel: Int, Codable, CaseIterable {
    case drained = 1, low = 2, neutral = 3, energized = 4, vibrant = 5

    var label: String {
        switch self {
        case .drained: return "Drained"
        case .low: return "Low"
        case .neutral: return "Neutral"
        case .energized: return "Energized"
        case .vibrant: return "Vibrant"
        }
    }
}
