import SwiftUI
import SwiftData

struct HabitRowView: View {
    let habit: Habit
    @Environment(\.modelContext) private var context
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 16) {
            Button {
                toggleComplete()
            } label: {
                Image(systemName: habit.completedToday ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(habit.completedToday ? .primary : Color(.systemGray3))
                    .scaleEffect(isAnimating ? 1.3 : 1.0)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .font(.subheadline)
                    .foregroundStyle(habit.completedToday ? .secondary : .primary)
                    .strikethrough(habit.completedToday)

                HStack(spacing: 6) {
                    Image(systemName: habit.category.icon)
                        .font(.caption2)
                    Text(habit.category.rawValue)
                        .font(.caption)
                    Text("·")
                    Text(habit.frequency.rawValue)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }

            Spacer()

            if let urlString = habit.mediaURL, let url = URL(string: urlString) {
                Button {
                    UIApplication.shared.open(url)
                } label: {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .opacity(habit.completedToday ? 0.6 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: habit.completedToday)
    }

    private func toggleComplete() {
        if habit.completedToday {
            if let log = habit.logs.first(where: { Calendar.current.isDateInToday($0.date) }) {
                context.delete(log)
            }
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = false
            }
            let log = HabitLog(habit: habit)
            context.insert(log)
        }

        try? context.save()
    }
}
