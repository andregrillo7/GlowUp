import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var notificationManager: NotificationManager
    @AppStorage("notificationToneRaw") private var notificationToneRaw: String = NotificationTone.cosmic.rawValue
    @AppStorage("morningCheckInHour") private var morningCheckInHour: Int = 8
    @AppStorage("checkInEnabled") private var checkInEnabled: Bool = true

    private var selectedTone: Binding<NotificationTone> {
        Binding(
            get: { NotificationTone(rawValue: notificationToneRaw) ?? .cosmic },
            set: { notificationToneRaw = $0.rawValue; notificationManager.notificationTone = $0 }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                notificationSection
                morningCheckInSection
                tonePreviewSection
                aboutSection
            }
            .navigationTitle("Settings")
        }
    }

    private var notificationSection: some View {
        Section("Notification Style") {
            Picker("Tone", selection: selectedTone) {
                ForEach(NotificationTone.allCases, id: \.self) { tone in
                    Text(tone.label).tag(tone)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
    }

    private var morningCheckInSection: some View {
        Section("Morning Check-in") {
            Toggle("Daily reminder", isOn: $checkInEnabled)
                .onChange(of: checkInEnabled) { _, enabled in
                    if enabled {
                        if notificationManager.isAuthorized {
                            notificationManager.scheduleDailyCheckIn(at: morningCheckInHour)
                        } else {
                            notificationManager.requestAuthorization()
                        }
                    } else {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(
                            withIdentifiers: ["daily-checkin"]
                        )
                    }
                }

            if checkInEnabled {
                Stepper("At \(morningCheckInHour):00", value: $morningCheckInHour, in: 5...11)
                    .onChange(of: morningCheckInHour) { _, hour in
                        notificationManager.scheduleDailyCheckIn(at: hour)
                    }
            }
        }
    }

    private var tonePreviewSection: some View {
        Section("Preview") {
            VStack(alignment: .leading, spacing: 8) {
                Text(notificationManager.notificationTone.title(for: "your habit"))
                    .font(.subheadline).bold()
                Text(notificationManager.notificationTone.body(for: "your habit"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("GlowUp")
                Spacer()
                Text("v1.0")
                    .foregroundStyle(.secondary)
            }
            Text("Built for the ADHD mind — show up, not perform.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

import UserNotifications
