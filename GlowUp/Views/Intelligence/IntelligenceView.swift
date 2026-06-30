import SwiftUI
import SwiftData

struct IntelligenceView: View {
    @Query(sort: \IntelligenceLog.date, order: .reverse) private var logs: [IntelligenceLog]
    @Environment(\.modelContext) private var context
    @State private var showAddLog = false

    private var todayMinutes: Int {
        logs.filter { Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.minutesSpent }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    todaySummary
                    logsList
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle("Growth")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAddLog = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddLog) {
            AddIntelligenceLogView()
        }
    }

    private var todaySummary: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Today")
                    .font(.headline)
                Text("\(todayMinutes) minutes of growth")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "brain")
                .font(.title)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var logsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent sessions")
                .font(.headline)

            if logs.isEmpty {
                Text("Log your reading, study, or practice sessions here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(logs) { log in
                    IntelligenceLogRow(log: log)
                }
            }
        }
    }
}

struct IntelligenceLogRow: View {
    let log: IntelligenceLog

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: log.type.icon)
                .font(.title3)
                .frame(width: 36, height: 36)
                .background(Color(.systemGray5))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(log.title)
                    .font(.subheadline).bold()
                HStack(spacing: 4) {
                    Text(log.type.rawValue)
                    Text("·")
                    Text("\(log.minutesSpent) min")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            if let urlString = log.mediaURL, let url = URL(string: urlString) {
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
    }
}
