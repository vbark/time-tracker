import SwiftUI

struct ManualEntryView: View {
    @Bindable var vm: TimeTrackerViewModel

    @State private var startTime = "09:00"
    @State private var endTime = "17:00"
    @State private var note = ""
    @State private var isOffDay = false
    @State private var showValidationError = false
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.accentColor)
                    Text("Add Entry")
                        .fontWeight(.medium)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .font(.subheadline)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            if isExpanded {
                Divider()
                    .padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Start")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("09:00", text: $startTime)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                                .monospacedDigit()
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("End")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("17:00", text: $endTime)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                                .monospacedDigit()
                        }
                        Spacer()
                        Toggle("Off Day", isOn: $isOffDay)
                            .toggleStyle(.checkbox)
                            .font(.caption)
                    }

                    TextField("Note (optional)", text: $note)
                        .textFieldStyle(.roundedBorder)

                    HStack {
                        Spacer()
                        Button {
                            addEntry()
                        } label: {
                            Text("Add")
                                .frame(width: 60)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                        .keyboardShortcut("n", modifiers: .command)
                    }
                }
                .padding(16)
                .transition(.opacity)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.ultraThinMaterial)
        }
        .alert("Invalid Time", isPresented: $showValidationError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please use HH:MM format (e.g. 09:00, 17:30)")
        }
    }

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
