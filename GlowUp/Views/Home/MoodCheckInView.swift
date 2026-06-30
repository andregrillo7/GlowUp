import SwiftUI
import SwiftData

struct MoodCheckInView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMood: MoodLevel = .good
    @State private var selectedEnergy: EnergyLevel = .neutral
    @State private var note = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                moodPicker
                energyPicker
                noteField
                Spacer()
                saveButton
            }
            .padding(24)
            .navigationTitle("How are you?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var moodPicker: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mood")
                .font(.headline)
            HStack(spacing: 12) {
                ForEach(MoodLevel.allCases, id: \.self) { mood in
                    VStack(spacing: 6) {
                        Text(mood.emoji)
                            .font(.title)
                        Text(mood.label)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedMood == mood ? Color(.systemGray5) : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onTapGesture { selectedMood = mood }
                }
            }
        }
    }

    private var energyPicker: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Energy")
                .font(.headline)
            HStack(spacing: 8) {
                ForEach(EnergyLevel.allCases, id: \.self) { energy in
                    Text(energy.label)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedEnergy == energy ? Color(.systemGray4) : Color(.systemGray6))
                        .clipShape(Capsule())
                        .onTapGesture { selectedEnergy = energy }
                }
            }
        }
    }

    private var noteField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Anything on your mind? (optional)")
                .font(.headline)
            TextField("Just a few words...", text: $note, axis: .vertical)
                .lineLimit(3...5)
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var saveButton: some View {
        Button {
            let entry = MoodEntry(mood: selectedMood, energy: selectedEnergy, note: note.isEmpty ? nil : note)
            context.insert(entry)
            try? context.save()
            dismiss()
        } label: {
            Text("Save check-in")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primary)
                .foregroundStyle(Color(uiColor: .systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
