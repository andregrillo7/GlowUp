import SwiftUI
import SwiftData

struct AddIntelligenceLogView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var type: IntelligenceType = .reading
    @State private var title = ""
    @State private var minutesSpent = 20
    @State private var mediaURL = ""
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Session") {
                    Picker("Type", selection: $type) {
                        ForEach(IntelligenceType.allCases, id: \.self) { t in
                            Label(t.rawValue, systemImage: t.icon).tag(t)
                        }
                    }
                    TextField("Title (book, topic, skill...)", text: $title)
                    Stepper("\(minutesSpent) minutes", value: $minutesSpent, in: 1...300, step: 5)
                }

                Section("Link (optional)") {
                    TextField("YouTube, Spotify, article...", text: $mediaURL)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }

                Section("Note (optional)") {
                    TextField("What did you learn or feel?", text: $note, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("Log Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                        .bold()
                }
            }
        }
    }

    private func save() {
        let log = IntelligenceLog(
            type: type,
            title: title.trimmingCharacters(in: .whitespaces),
            minutesSpent: minutesSpent,
            mediaURL: mediaURL.isEmpty ? nil : mediaURL,
            note: note.isEmpty ? nil : note
        )
        context.insert(log)
        try? context.save()
        dismiss()
    }
}
