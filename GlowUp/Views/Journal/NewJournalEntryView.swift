import SwiftUI
import SwiftData

struct NewJournalEntryView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var selectedFactors: Set<WellbeingFactor> = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    journalField
                    wellbeingFactorsSection
                }
                .padding(20)
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                        .bold()
                }
            }
        }
    }

    private var journalField: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What's on your mind?")
                .font(.headline)
            TextField("Write freely — this is just for you.", text: $text, axis: .vertical)
                .lineLimit(6...12)
                .padding(14)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private var wellbeingFactorsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What's affecting your wellbeing today?")
                .font(.headline)
            Text("Select all that apply")
                .font(.caption)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(WellbeingFactor.allCases, id: \.self) { factor in
                    let isSelected = selectedFactors.contains(factor)
                    Button {
                        if isSelected { selectedFactors.remove(factor) }
                        else { selectedFactors.insert(factor) }
                    } label: {
                        Label(factor.rawValue, systemImage: factor.icon)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(isSelected ? Color(.systemGray4) : Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
    }

    private func save() {
        let entry = JournalEntry(
            text: text.trimmingCharacters(in: .whitespaces),
            wellbeingFactors: Array(selectedFactors)
        )
        context.insert(entry)
        try? context.save()
        dismiss()
    }
}
