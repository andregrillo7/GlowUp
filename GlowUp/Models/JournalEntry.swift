import SwiftData
import Foundation

@Model
final class JournalEntry {
    var id: UUID
    var date: Date
    var text: String
    var wellbeingFactors: [WellbeingFactor]

    init(text: String, wellbeingFactors: [WellbeingFactor] = []) {
        self.id = UUID()
        self.date = Date()
        self.text = text
        self.wellbeingFactors = wellbeingFactors
    }
}

enum WellbeingFactor: String, Codable, CaseIterable {
    case sleep = "Sleep"
    case nutrition = "Nutrition"
    case movement = "Movement"
    case socialConnection = "Social Connection"
    case stress = "Stress"
    case sunlight = "Sunlight"
    case hydration = "Hydration"
    case screenTime = "Screen Time"
    case alcohol = "Alcohol"
    case nature = "Nature"

    var icon: String {
        switch self {
        case .sleep: return "moon"
        case .nutrition: return "fork.knife"
        case .movement: return "figure.walk"
        case .socialConnection: return "person.2"
        case .stress: return "bolt"
        case .sunlight: return "sun.max"
        case .hydration: return "drop"
        case .screenTime: return "iphone"
        case .alcohol: return "wineglass"
        case .nature: return "leaf"
        }
    }
}
