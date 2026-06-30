import SwiftUI
import SwiftData

struct AddHabitView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var notificationManager: NotificationManager

    @State private var name = ""
    @State private var category: HabitCategory = .body
    @State private var frequency: HabitFrequency = .daily
    @State private var mediaURL = ""
    @State private var enableNotification = false
    @State private var notificationHour = 8
    @State private var notificationMinute = 0

    var body: some View {
        NavigationStack {
            Form {
                Section("Habit") {
                    TextField("e.g. Morning skincare", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(HabitCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                    Picker("Frequency", selection: $frequency) {
                        ForEach(HabitFrequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                }

                Section("Launch Link (optional)") {
                    TextField("Paste YouTube, TikTok, or app link", text: $mediaURL)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    if !mediaURL.isEmpty {
                        Text("Tap the play button on home screen to open instantly")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Reminder") {
                    Toggle("Set daily reminder", isOn: $enableNotification)
                    if enableNotification {
                        DatePicker(
                            "Time",
                            selection: Binding(
                                get: {
                                    var components = DateComponents()
                                    components.hour = notificationHour
                                    components.minute = notificationMinute
                                    return Calendar.current.date(from: components) ?? Date()
                                },
                                set: { date in
                                    notificationHour = Calendar.current.component(.hour, from: date)
                                    notificationMinute = Calendar.current.component(.minute, from: date)
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                    }
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                        .bold()
                }
            }
        }
    }

    private func save() {
        let habit = Habit(
            name: name.trimmingCharacters(in: .whitespaces),
            category: category,
            frequency: frequency,
            mediaURL: mediaURL.isEmpty ? nil : mediaURL
        )
        context.insert(habit)
        try? context.save()

        if enableNotification {
            if notificationManager.isAuthorized {
                notificationManager.scheduleHabitNotification(for: habit, at: notificationHour, minute: notificationMinute)
            } else {
                notificationManager.requestAuthorization()
            }
        }

        dismiss()
    }
}
