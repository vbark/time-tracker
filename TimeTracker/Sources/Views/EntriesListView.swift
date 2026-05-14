import SwiftUI

/// Table of time entries for the selected day with edit and delete support.
struct EntriesListView: View {
    @Bindable var vm: TimeTrackerViewModel

    @State private var selectedEntryID: TimeEntry.ID?
    @State private var editingEntry: TimeEntry?
    @State private var entryToDelete: TimeEntry?

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                dateHeader
                entriesTable
            }
            .padding(.vertical, 4)
        } label: {
            Label("Entries", systemImage: "list.bullet.rectangle")
                .font(.headline)
        }
    }

    // MARK: - Date Header

    private var dateHeader: some View {
        Text("Showing entries for \(DateFormatter.fullDate.string(from: vm.selectedDate))")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }

    // MARK: - Entries Table

    private var entriesTable: some View {
        Group {
            if vm.selectedDayEntries.isEmpty {
                ContentUnavailableView(
                    "No Entries",
                    systemImage: "clock",
                    description: Text("No time entries for this day. Start the timer or add one manually.")
                )
                .frame(minHeight: 120)
            } else {
                Table(vm.selectedDayEntries, selection: $selectedEntryID) {
                    TableColumn("Time") { entry in
                        Text(entry.timeRangeDisplay)
                            .monospacedDigit()
                    }
                    .width(min: 100, ideal: 130)

                    TableColumn("Duration") { entry in
                        Text(entry.duration)
                            .monospacedDigit()
                    }
                    .width(min: 60, ideal: 80)

                    TableColumn("Note") { entry in
                        Text(entry.note)
                            .lineLimit(1)
                    }
                    .width(min: 100, ideal: 180)

                    TableColumn("Type") { entry in
                        Text(entry.typeDisplay)
                            .foregroundStyle(entry.isOffDay ? .red : .primary)
                    }
                    .width(min: 60, ideal: 80)
                }
                .tableStyle(.bordered(alternatesRowBackgrounds: true))
                .frame(minHeight: CGFloat(vm.selectedDayEntries.count * 30 + 40))
                .contextMenu(forSelectionType: TimeEntry.ID.self) { ids in
                    if let id = ids.first, let entry = vm.selectedDayEntries.first(where: { $0.id == id }) {
                        Button("Edit") { editingEntry = entry }
                        Button("Delete", role: .destructive) { entryToDelete = entry }
                    }
                } primaryAction: { ids in
                    if let id = ids.first, let entry = vm.selectedDayEntries.first(where: { $0.id == id }) {
                        editingEntry = entry
                    }
                }
            }
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
        VStack(spacing: 16) {
            Text("Edit Entry")
                .font(.headline)

            Form {
                TextField("Start Time", text: $startTime)
                TextField("End Time", text: $endTime)
                TextField("Note", text: $note)
                Toggle("Off Day", isOn: $isOffDay)
            }

            HStack {
                Button("Cancel", role: .cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Save") { save() }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 340)
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
