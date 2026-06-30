import SwiftUI
import SwiftData

struct JournalView: View {
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    @Query(sort: \MoodEntry.date, order: .reverse) private var moods: [MoodEntry]
    @State private var showNewEntry = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    wellbeingSection
                    entriesSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showNewEntry = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showNewEntry) {
            NewJournalEntryView()
        }
    }

    private var wellbeingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What's affecting you lately")
                .font(.headline)

            let recentFactors = recentWellbeingFactors()
            if recentFactors.isEmpty {
                Text("Your patterns will appear here as you journal.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(recentFactors, id: \.self) { factor in
                            Label(factor.rawValue, systemImage: factor.icon)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(Color(.systemGray6))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }

    private var entriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Entries")
                .font(.headline)

            if entries.isEmpty {
                Text("Nothing yet — tap + to write your first entry.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(entries) { entry in
                    JournalEntryRow(entry: entry)
                }
            }
        }
    }

    private func recentWellbeingFactors() -> [WellbeingFactor] {
        let recent = entries.prefix(10).flatMap { $0.wellbeingFactors }
        let counts = Dictionary(grouping: recent, by: { $0 }).mapValues { $0.count }
        return counts.sorted { $0.value > $1.value }.prefix(5).map { $0.key }
    }
}

struct JournalEntryRow: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(entry.text)
                .font(.subheadline)
                .lineLimit(3)

            if !entry.wellbeingFactors.isEmpty {
                HStack(spacing: 6) {
                    ForEach(entry.wellbeingFactors.prefix(4), id: \.self) { factor in
                        Image(systemName: factor.icon)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
