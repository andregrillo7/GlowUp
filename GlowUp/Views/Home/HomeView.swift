import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(filter: #Predicate<Habit> { $0.isActive }) private var habits: [Habit]
    @Query(sort: \MoodEntry.date, order: .reverse) private var moods: [MoodEntry]
    @Environment(\.modelContext) private var context
    @State private var showMoodCheck = false
    @State private var todayMood: MoodEntry?

    private var todaysMood: MoodEntry? {
        moods.first { Calendar.current.isDateInToday($0.date) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    headerSection
                    moodSection
                    habitsSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle(greeting)
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showMoodCheck) {
            MoodCheckInView()
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date().formatted(date: .complete, time: .omitted))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            let done = habits.filter { $0.completedToday }.count
            Text("\(done) of \(habits.count) done today")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How are you feeling?")
                .font(.headline)

            if let mood = todaysMood {
                HStack {
                    Text(mood.mood.emoji)
                        .font(.title2)
                    VStack(alignment: .leading) {
                        Text(mood.mood.label)
                            .font(.subheadline).bold()
                        Text("Energy: \(mood.energy.label)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Update") { showMoodCheck = true }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                Button {
                    showMoodCheck = true
                } label: {
                    HStack {
                        Text("Check in — takes 10 seconds")
                            .font(.subheadline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .foregroundStyle(.primary)
            }
        }
    }

    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's habits")
                .font(.headline)

            if habits.isEmpty {
                Text("No habits yet — add some in the Habits tab.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            } else {
                ForEach(habits) { habit in
                    HabitRowView(habit: habit)
                }
            }
        }
    }
}
