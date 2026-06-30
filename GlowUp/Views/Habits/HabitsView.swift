import SwiftUI
import SwiftData

struct HabitsView: View {
    @Query(filter: #Predicate<Habit> { $0.isActive }, sort: \Habit.createdAt) private var habits: [Habit]
    @Environment(\.modelContext) private var context
    @State private var showAddHabit = false
    @State private var selectedCategory: HabitCategory? = nil

    private var filteredHabits: [Habit] {
        guard let cat = selectedCategory else { return habits }
        return habits.filter { $0.category == cat }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    categoryFilter
                    habitsList
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAddHabit = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddHabit) {
            AddHabitView()
        }
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(label: "All", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(HabitCategory.allCases, id: \.self) { cat in
                    filterChip(label: cat.rawValue, isSelected: selectedCategory == cat) {
                        selectedCategory = selectedCategory == cat ? nil : cat
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func filterChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.primary : Color(.systemGray6))
                .foregroundStyle(isSelected ? Color(uiColor: .systemBackground) : .primary)
                .clipShape(Capsule())
        }
    }

    private var habitsList: some View {
        VStack(spacing: 10) {
            if filteredHabits.isEmpty {
                Text("No habits yet. Tap + to add one.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 20)
            } else {
                ForEach(filteredHabits) { habit in
                    HabitDetailRow(habit: habit)
                }
            }
        }
    }
}

struct HabitDetailRow: View {
    let habit: Habit
    @Environment(\.modelContext) private var context

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: habit.category.icon)
                .font(.title3)
                .frame(width: 36, height: 36)
                .background(Color(.systemGray5))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(habit.name)
                    .font(.subheadline).bold()
                Text("\(habit.frequency.rawValue) · \(habit.category.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(habit.consistencyScore * 100))%")
                    .font(.subheadline).bold()
                Text("consistent")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                habit.isActive = false
                try? context.save()
            } label: {
                Label("Archive", systemImage: "archivebox")
            }
        }
    }
}
