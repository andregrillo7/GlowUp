import SwiftData
import Foundation

@Model
final class IntelligenceLog {
    var id: UUID
    var date: Date
    var type: IntelligenceType
    var title: String
    var minutesSpent: Int
    var mediaURL: String?
    var note: String?

    init(type: IntelligenceType, title: String, minutesSpent: Int, mediaURL: String? = nil, note: String? = nil) {
        self.id = UUID()
        self.date = Date()
        self.type = type
        self.title = title
        self.minutesSpent = minutesSpent
        self.mediaURL = mediaURL
        self.note = note
    }
}

enum IntelligenceType: String, Codable, CaseIterable {
    case reading = "Reading"
    case study = "Study"
    case hobby = "Hobby"
    case podcast = "Podcast"
    case course = "Course"

    var icon: String {
        switch self {
        case .reading: return "book"
        case .study: return "graduationcap"
        case .hobby: return "paintbrush"
        case .podcast: return "headphones"
        case .course: return "play.circle"
        }
    }
}
