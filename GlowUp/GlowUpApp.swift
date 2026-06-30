import SwiftUI
import SwiftData
import UserNotifications

@main
struct GlowUpApp: App {
    @StateObject private var notificationManager = NotificationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationManager)
        }
        .modelContainer(for: [
            Habit.self,
            HabitLog.self,
            JournalEntry.self,
            MoodEntry.self,
            ProgressPhoto.self,
            IntelligenceLog.self
        ])
    }
}
