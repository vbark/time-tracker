import SwiftUI
import UniformTypeIdentifiers

/// Settings view for configuring storage paths and daily target hours.
/// Presented via the Settings scene (Cmd+,).
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

                    HStack {
                        statusIndicator
                        Spacer()
                    }
                }

                HStack {
                    Button("Choose File...") { showFileImporter = true }
                    Button("Reset to Default") { resetStorage() }
                }
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 420, minHeight: 250)
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

    private var statusIndicator: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(vm.storage.hasWarning ? .orange : .green)
                .frame(width: 8, height: 8)
            Text(vm.storage.statusMessage)
                .font(.caption)
                .foregroundStyle(vm.storage.hasWarning ? .orange : .secondary)
        }
    }

    private func resetStorage() {
        vm.storage.resetToDefault()
        vm.refreshData()
    }
}
