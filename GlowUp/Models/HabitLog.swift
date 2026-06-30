import SwiftData
import Foundation

@Model
final class HabitLog {
    var id: UUID
    var date: Date
    var completed: Bool
    var note: String?
    var habit: Habit?

    init(habit: Habit, completed: Bool = true, note: String? = nil) {
        self.id = UUID()
        self.date = Date()
        self.completed = completed
        self.note = note
        self.habit = habit
    }
}
