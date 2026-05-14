import SwiftUI

/// Menu bar popover content: shows timer status, today's total, and quick actions.
struct MenuBarView: View {
    @Bindable var vm: TimeTrackerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection
            Divider()
            timerSection
            Divider()
            todaySection
            Divider()
            footerActions
        }
        .padding(16)
        .frame(width: 260)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Text("Time Tracker")
                .font(.headline)
            Spacer()
            Text(HoursFormatter.signedBalance(vm.totalBalance))
                .font(.system(.caption, design: .monospaced, weight: .bold))
                .foregroundStyle(Color.balanceColor(for: vm.totalBalance))
        }
    }

    // MARK: - Timer

    private var timerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Circle()
                    .fill(vm.timerIsRunning ? .green : .secondary)
                    .frame(width: 8, height: 8)
                Text(vm.timerIsRunning ? "Running" : "Stopped")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(vm.timerDisplay)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .center)

            if vm.timerIsRunning {
                Text(vm.timerStatusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button(action: vm.toggleTimer) {
                HStack {
                    Image(systemName: vm.timerIsRunning ? "stop.fill" : "play.fill")
                    Text(vm.timerIsRunning ? "Stop" : "Start")
                }
                .frame(maxWidth: .infinity)
            }
            .controlSize(.small)
            .buttonStyle(.borderedProminent)
            .tint(vm.timerIsRunning ? .red : .green)
        }
    }

    // MARK: - Today's Summary

    private var todaySection: some View {
        let todayStr = DateFormatter.isoDate.string(from: .now)
        let todayHours = vm.entries
            .filter { $0.dateString == todayStr && !$0.isOffDay }
            .reduce(0.0) { $0 + $1.durationHours }

        return VStack(alignment: .leading, spacing: 4) {
            Text("Today")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Text(HoursFormatter.duration(todayHours))
                    .font(.system(.body, design: .rounded, weight: .semibold))
                Text("/ \(HoursFormatter.rounded(vm.settings.dailyTargetHours))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: min(todayHours / vm.settings.dailyTargetHours, 1.0))
                .tint(todayHours >= vm.settings.dailyTargetHours ? .balancePositive : .accentBlue)
        }
    }

    // MARK: - Footer

    private var footerActions: some View {
        HStack {
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
            Spacer()
        }
    }
}
