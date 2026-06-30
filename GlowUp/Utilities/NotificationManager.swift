import Foundation
import UserNotifications

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var isAuthorized = false
    @Published var notificationTone: NotificationTone = .cosmic

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkAuthorization()
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { self.isAuthorized = granted }
        }
    }

    private func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    func scheduleHabitNotification(for habit: Habit, at hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = notificationTone.title(for: habit.name)
        content.body = notificationTone.body(for: habit.name)
        content.sound = .default
        content.userInfo = ["habitName": habit.name]

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: "habit-\(habit.id)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func scheduleDailyCheckIn(at hour: Int = 8) {
        let content = UNMutableNotificationContent()
        content.title = notificationTone.morningTitle
        content.body = notificationTone.morningBody
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-checkin", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func removeNotification(for habitID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["habit-\(habitID)"]
        )
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

enum NotificationTone: String, CaseIterable, Codable {
    case cosmic = "Cosmic & Meaningful"
    case warm = "Warm & Gentle"
    case hype = "Hype & Energize"
    case dry = "Dry & Direct"
    case playful = "Curious & Playful"

    var label: String { rawValue }

    func title(for habitName: String) -> String {
        switch self {
        case .cosmic: return "The universe is nudging you ✨"
        case .warm: return "Hey, you \u{2014} this is for you 🌸"
        case .hype: return "LET'S GO. \(habitName) time 🔥"
        case .dry: return "\(habitName). Now. You'll feel better."
        case .playful: return "What if today was the day? 👀"
        }
    }

    func body(for habitName: String) -> String {
        switch self {
        case .cosmic: return "\(habitName) is waiting. Your future self already knows."
        case .warm: return "You don't have to be perfect. Just show up for \(habitName)."
        case .hype: return "One tap. That's all. You've done harder things."
        case .dry: return "5 minutes. That's it."
        case .playful: return "Tap to find out what happens when you actually do \(habitName) today."
        }
    }

    var morningTitle: String {
        switch self {
        case .cosmic: return "A new day, a new chance ✨"
        case .warm: return "Good morning, beautiful 🌸"
        case .hype: return "RISE UP. Today is yours 🔥"
        case .dry: return "Morning. Check in."
        case .playful: return "Plot twist: today goes well 👀"
        }
    }

    var morningBody: String {
        switch self {
        case .cosmic: return "The version of you that shows up today matters."
        case .warm: return "How are you feeling? Take a moment just for you."
        case .hype: return "Open the app. Log your mood. Start strong."
        case .dry: return "Log your check-in. Takes 30 seconds."
        case .playful: return "Your habits are curious about you. Open up."
        }
    }
}
