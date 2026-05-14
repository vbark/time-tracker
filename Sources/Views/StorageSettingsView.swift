import SwiftUI
import UniformTypeIdentifiers

struct StorageSettingsView: View {
    @Bindable var vm: TimeTrackerViewModel

    @State private var showFileImporter = false

    var body: some View {
        Form {
            Section("Work Target") {
                HStack {
                    Text("Daily target hours")
                    Spacer()
                    TextField("Hours", value: $vm.settings.dailyTargetHours, format: .number)
                        .frame(width: 60)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section("Storage") {
                VStack(alignment: .leading, spacing: 8) {
                    LabeledContent("Primary") {
                        Text(vm.storage.primaryURL.path)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .truncationMode(.middle)
                    }

                    LabeledContent("Backup") {
                        Text(vm.storage.backupURL.path)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .truncationMode(.middle)
                    }

                    HStack(spacing: 4) {
                        Circle()
                            .fill(vm.storage.hasWarning ? .orange : .green)
                            .frame(width: 8, height: 8)
                        Text(vm.storage.statusMessage)
                            .font(.caption)
                            .foregroundStyle(vm.storage.hasWarning ? .orange : .secondary)
                    }
                }

                HStack {
                    Button("Choose File...") { showFileImporter = true }
                    Button("Reset to Default") {
                        vm.storage.resetToDefault()
                        vm.refreshData()
                    }
                }
            }

            Section("Startup") {
                Toggle("Open Time Tracker at login", isOn: Binding(
                    get: { vm.launchAtLogin.isEnabled },
                    set: { vm.launchAtLogin.setEnabled($0) }
                ))
                Text(vm.launchAtLogin.statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Timer Notifications") {
                HStack {
                    Text("Notify after active (minutes)")
                    Spacer()
                    TextField("Minutes", value: $vm.settings.reminderDelayMinutes, format: .number)
                        .frame(width: 60)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Snooze after decline (minutes)")
                    Spacer()
                    TextField("Minutes", value: $vm.settings.reminderSnoozeMinutes, format: .number)
                        .frame(width: 60)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                }
                Toggle("Enable timer notifications", isOn: $vm.settings.reminderEnabled)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 460, minHeight: 430)
        .onAppear {
            vm.launchAtLogin.refresh()
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [UTType(filenameExtension: "csv") ?? .commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                vm.storage.setPrimaryPath(url.path)
                vm.refreshData()
            }
        }
    }
}
