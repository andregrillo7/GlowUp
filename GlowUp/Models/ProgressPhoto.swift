import SwiftData
import Foundation

@Model
final class ProgressPhoto {
    var id: UUID
    var date: Date
    var type: PhotoType
    var imageData: Data
    var note: String?

    init(type: PhotoType, imageData: Data, note: String? = nil) {
        self.id = UUID()
        self.date = Date()
        self.type = type
        self.imageData = imageData
        self.note = note
    }
}

enum PhotoType: String, Codable, CaseIterable {
    case face = "Face"
    case body = "Body"
    case emotional = "Emotional"

    var icon: String {
        switch self {
        case .face: return "face.smiling"
        case .body: return "figure.stand"
        case .emotional: return "heart.circle"
        }
    }

    var prompt: String {
        switch self {
        case .face: return "How's your skin & face today?"
        case .body: return "Full body check-in"
        case .emotional: return "How do you look when you feel this way?"
        }
    }
}
