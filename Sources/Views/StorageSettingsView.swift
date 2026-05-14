import SwiftUI
import UniformTypeIdentifiers

struct StorageSettingsView: View {
    @Bindable var vm: TimeTrackerViewModel

    @State private var showFileImporter = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header
            HStack(alignment: .top, spacing: 16) {
                VStack(spacing: 14) {
                    targetCard
                    startupCard
                    notificationCard
                }
                VStack(spacing: 14) {
                    storageCard
                }
            }
            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(width: 680, height: 520)
        .background(Color.subtleBackground)
        .onAppear {
            vm.launchAtLogin.refresh()
            Task {
                await vm.notifications.refreshAuthorizationStatus()
            }
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

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Settings")
                .font(.system(.title2, design: .rounded, weight: .semibold))
            Text("Keep Time Tracker ready, visible, and hard to forget.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var targetCard: some View {
        SettingsCard(title: "Work Target", systemImage: "target") {
            SettingsNumberRow(
                title: "Daily target",
                suffix: "hours",
                value: $vm.settings.dailyTargetHours
            )
        }
    }

    private var startupCard: some View {
        SettingsCard(title: "Startup", systemImage: "power") {
            Toggle("Open at login", isOn: Binding(
                get: { vm.launchAtLogin.isEnabled },
                set: { vm.launchAtLogin.setEnabled($0) }
            ))
            .toggleStyle(.switch)
        }
    }

    private var notificationCard: some View {
        SettingsCard(title: "Timer Notifications", systemImage: "bell.badge") {
            Toggle("Enabled", isOn: $vm.settings.reminderEnabled)
                .toggleStyle(.switch)

            SettingsIntegerRow(
                title: "Active delay",
                suffix: "min",
                value: $vm.settings.reminderDelayMinutes
            )

            SettingsIntegerRow(
                title: "Snooze",
                suffix: "min",
                value: $vm.settings.reminderSnoozeMinutes
            )

            Divider()

            HStack {
                statusPill(text: vm.notifications.authorizationStatusText, isGood: vm.notifications.isAuthorized)
                Spacer()
                Button("Test") {
                    vm.notifications.sendTestReminder()
                }
                .controlSize(.small)
            }
        }
    }

    private var storageCard: some View {
        SettingsCard(title: "Storage", systemImage: "externaldrive") {
            StoragePathRow(title: "Primary", path: vm.storage.primaryURL.path)
            StoragePathRow(title: "Backup", path: vm.storage.backupURL.path)

            HStack(spacing: 6) {
                Circle()
                    .fill(vm.storage.hasWarning ? Color.warningOrange : Color.balancePositive)
                    .frame(width: 8, height: 8)
                Text(vm.storage.statusMessage)
                    .font(.caption)
                    .foregroundStyle(vm.storage.hasWarning ? Color.warningOrange : .secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            HStack {
                Button("Choose...") { showFileImporter = true }
                Button("Reset") {
                    vm.storage.resetToDefault()
                    vm.refreshData()
                }
                Spacer()
            }
            .controlSize(.small)
        }
    }

    private func statusPill(text: String, isGood: Bool) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(isGood ? Color.balancePositive : Color.warningOrange)
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background {
                Capsule()
                    .fill((isGood ? Color.balancePositive : Color.warningOrange).opacity(0.12))
            }
    }
}

private struct SettingsCard<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(.primary)
                .symbolRenderingMode(.hierarchical)
            content
        }
        .padding(16)
        .frame(width: 310, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
                .stroke(Color.cardBorder.opacity(0.5), lineWidth: 1)
        }
    }
}

private struct SettingsNumberRow: View {
    let title: String
    let suffix: String
    @Binding var value: Double

    var body: some View {
        HStack {
            Text(title)
                .lineLimit(1)
            Spacer()
            TextField("", value: $value, format: .number)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.trailing)
                .frame(width: 64)
            Text(suffix)
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .leading)
        }
    }
}

private struct SettingsIntegerRow: View {
    let title: String
    let suffix: String
    @Binding var value: Int

    var body: some View {
        HStack {
            Text(title)
                .lineLimit(1)
            Spacer()
            TextField("", value: $value, format: .number)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.trailing)
                .frame(width: 58)
            Text(suffix)
                .foregroundStyle(.secondary)
                .frame(width: 28, alignment: .leading)
        }
    }
}

private struct StoragePathRow: View {
    let title: String
    let path: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            Text(path)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
                .textSelection(.enabled)
        }
    }
}
