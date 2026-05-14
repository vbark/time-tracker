import SwiftUI

struct EntriesListView: View {
    @Bindable var vm: TimeTrackerViewModel

    @State private var selectedEntryID: TimeEntry.ID?
    @State private var editingEntry: TimeEntry?
    @State private var entryToDelete: TimeEntry?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(DateFormatter.fullDate.string(from: vm.selectedDate))
                        .font(.headline)
                    Text("\(vm.selectedDayEntries.count) entries")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            if vm.selectedDayEntries.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 28))
                        .foregroundStyle(.quaternary)
                    Text("No entries for this day")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Start the timer or add one manually")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                Divider()
                    .padding(.horizontal, 16)

                VStack(spacing: 0) {
                    ForEach(vm.selectedDayEntries) { entry in
                        Button {
                            selectedEntryID = entry.id
                        } label: {
                            EntryRow(entry: entry, isSelected: entry.id == selectedEntryID)
                        }
                            .buttonStyle(.plain)
                            .contentShape(Rectangle())
                            .accessibilityLabel("\(entry.typeDisplay), \(entry.timeRangeDisplay), \(entry.duration)")
                            .accessibilityHint("Select entry")
                            .contextMenu {
                                Button("Edit") { editingEntry = entry }
                                Divider()
                                Button("Delete", role: .destructive) { entryToDelete = entry }
                            }

                        if entry.id != vm.selectedDayEntries.last?.id {
                            Divider()
                                .padding(.leading, 52)
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.cardBackground)
                .stroke(Color.cardBorder.opacity(0.65), lineWidth: 1)
        }
        .sheet(item: $editingEntry) { entry in
            EditEntrySheet(vm: vm, entry: entry)
        }
        .alert("Delete Entry?", isPresented: Binding(
            get: { entryToDelete != nil },
            set: { if !$0 { entryToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) { entryToDelete = nil }
            Button("Delete", role: .destructive) {
                if let entry = entryToDelete {
                    vm.deleteEntry(entry)
                    entryToDelete = nil
                }
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
}

// MARK: - Entry Row

private struct EntryRow: View {
    let entry: TimeEntry
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(entry.isOffDay ? Color.balanceNegative : Color.accentPurple)
                .frame(width: 4, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                if entry.isOffDay {
                    Text("Off Day")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.balanceNegative)
                } else {
                    Text(entry.timeRangeDisplay)
                        .font(.system(.subheadline, design: .monospaced))
                        .fontWeight(.medium)
                }
                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if !entry.isOffDay {
                Text(entry.duration)
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.accentPurple.opacity(0.12))
            }
        }
    }
}

// MARK: - Edit Entry Sheet

private struct EditEntrySheet: View {
    @Bindable var vm: TimeTrackerViewModel
    let entry: TimeEntry

    @State private var startTime: String
    @State private var endTime: String
    @State private var note: String
    @State private var isOffDay: Bool
    @Environment(\.dismiss) private var dismiss

    init(vm: TimeTrackerViewModel, entry: TimeEntry) {
        self.vm = vm
        self.entry = entry
        _startTime = State(initialValue: entry.startTime)
        _endTime = State(initialValue: entry.endTime)
        _note = State(initialValue: entry.note)
        _isOffDay = State(initialValue: entry.isOffDay)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Entry")
                .font(.headline)

            Form {
                TextField("Start Time", text: $startTime)
                TextField("End Time", text: $endTime)
                TextField("Note", text: $note)
                Toggle("Off Day", isOn: $isOffDay)
            }
            .formStyle(.grouped)

            HStack {
                Button("Cancel", role: .cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button("Save") { save() }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 360)
    }

    private func save() {
        var updated = entry
        updated.startTime = startTime
        updated.endTime = endTime
        updated.note = note
        updated.isOffDay = isOffDay
        updated.duration = TimeEntry.calculateDuration(start: startTime, end: endTime, isOffDay: isOffDay)
        vm.updateEntry(updated)
        dismiss()
    }
}
