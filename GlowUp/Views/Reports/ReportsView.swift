import SwiftUI
import SwiftData
import Charts

struct ReportsView: View {
    @Query(sort: \MoodEntry.date) private var moods: [MoodEntry]
    @Query(filter: #Predicate<Habit> { $0.isActive }) private var habits: [Habit]
    @Query(sort: \HabitLog.date, order: .reverse) private var logs: [HabitLog]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    consistencySection
                    moodSection
                    streakSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle("Reports")
        }
    }

    private var consistencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Consistency (last 30 days)")
                .font(.headline)

            ForEach(habits.sorted { $0.consistencyScore > $1.consistencyScore }) { habit in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(habit.name)
                            .font(.subheadline)
                        Spacer()
                        Text("\(Int(habit.consistencyScore * 100))%")
                            .font(.subheadline).bold()
                    }
                    ProgressView(value: habit.consistencyScore)
                        .tint(consistencyColor(habit.consistencyScore))
                }
                .padding(14)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood over time")
                .font(.headline)

            let recentMoods = moods.suffix(14)
            if recentMoods.count < 2 {
                Text("Log your mood for a few days to see your trend.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Chart(Array(recentMoods)) { entry in
                    LineMark(
                        x: .value("Date", entry.date),
                        y: .value("Mood", entry.mood.rawValue)
                    )
                    .interpolationMethod(.catmullRom)
                    PointMark(
                        x: .value("Date", entry.date),
                        y: .value("Mood", entry.mood.rawValue)
                    )
                }
                .chartYScale(domain: 1...5)
                .chartYAxis {
                    AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                        AxisValueLabel {
                            if let v = value.as(Int.self),
                               let mood = MoodLevel(rawValue: v) {
                                Text(mood.emoji).font(.caption2)
                            }
                        }
                    }
                }
                .frame(height: 160)
                .padding(14)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var streakSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This week")
                .font(.headline)

            let days = last7Days()
            HStack(spacing: 6) {
                ForEach(days, id: \.self) { day in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(hasAnyLog(on: day) ? Color.primary : Color(.systemGray5))
                            .frame(width: 32, height: 32)
                            .overlay {
                                if hasAnyLog(on: day) {
                                    Image(systemName: "checkmark")
                                        .font(.caption2.bold())
                                        .foregroundStyle(Color(uiColor: .systemBackground))
                                }
                            }
                        Text(day.formatted(.dateTime.weekday(.narrow)))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(14)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func consistencyColor(_ score: Double) -> Color {
        switch score {
        case 0.8...: return .primary
        case 0.5..<0.8: return Color(.systemOrange)
        default: return Color(.systemGray3)
        }
    }

    private func last7Days() -> [Date] {
        (0..<7).map { Calendar.current.date(byAdding: .day, value: -6 + $0, to: Date())! }
            .map { Calendar.current.startOfDay(for: $0) }
    }

    private func hasAnyLog(on day: Date) -> Bool {
        logs.contains { Calendar.current.startOfDay(for: $0.date) == day }
    }
}
