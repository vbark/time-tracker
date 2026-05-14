import SwiftUI

/// Form for adding a manual time entry with start/end times, note, and off-day toggle.
struct ManualEntryView: View {
    @Bindable var vm: TimeTrackerViewModel

    @State private var startTime = "09:00"
    @State private var endTime = "17:00"
    @State private var note = ""
    @State private var isOffDay = false
    @State private var showValidationError = false

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                timeInputRow
                noteField
                offDayToggle
                addButton
            }
            .padding(.vertical, 4)
        } label: {
            Label("Add Entry", systemImage: "pencil.line")
                .font(.headline)
        }
    }

    // MARK: - Subviews

    private var timeInputRow: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Start")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("09:00", text: $startTime)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("End")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("17:00", text: $endTime)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
            }
            Spacer()
        }
    }

    private var noteField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Note (optional)")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("What did you work on?", text: $note)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var offDayToggle: some View {
        Toggle("Off Day (won't affect balance)", isOn: $isOffDay)
            .toggleStyle(.checkbox)
    }

    private var addButton: some View {
        HStack {
            Spacer()
            Button {
                addEntry()
            } label: {
                Label("Add Entry", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut("n", modifiers: .command)
            Spacer()
        }
        .alert("Invalid Time", isPresented: $showValidationError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please use HH:MM format (e.g. 09:00, 17:30)")
        }
    }

    // MARK: - Logic

    private func addEntry() {
        let formatter = DateFormatter.hourMinute
        guard formatter.date(from: startTime) != nil,
              formatter.date(from: endTime) != nil else {
            showValidationError = true
            return
        }
        vm.addManualEntry(startTime: startTime, endTime: endTime, note: note, isOffDay: isOffDay)
        note = ""
        isOffDay = false
    }
}
