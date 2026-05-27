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
                        .foregroundStyle(Color.accentPurple)
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

                VStack(alignment: .leading, spacing: 12) {
                    timeAndOffDayRow

                    HStack(alignment: .center, spacing: 10) {
                        TextField("Note (optional)", text: $note)
                            .textFieldStyle(.roundedBorder)

                        Button {
                            addEntry()
                        } label: {
                            Text("Add")
                                .frame(minWidth: 64)
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
                .fill(Color.cardBackground)
                .stroke(Color.cardBorder.opacity(0.65), lineWidth: 1)
        }
        .alert("Invalid Time", isPresented: $showValidationError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please use HH:MM format (e.g. 09:00, 17:30)")
        }
    }

    private var timeAndOffDayRow: some View {
        HStack(alignment: .bottom, spacing: 12) {
            timeField(label: "Start", text: $startTime, placeholder: "09:00")
            timeField(label: "End", text: $endTime, placeholder: "17:00")

            Toggle("Off Day", isOn: $isOffDay)
                .toggleStyle(.checkbox)
                .font(.caption)
                .padding(.bottom, 4)

            Spacer(minLength: 0)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.secondaryCardBackground)
        }
    }

    private func timeField(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField(placeholder, text: text)
                .textFieldStyle(.roundedBorder)
                .frame(width: 76)
                .monospacedDigit()
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
