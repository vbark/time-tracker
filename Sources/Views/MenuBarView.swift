import SwiftUI

struct MenuBarView: View {
    @Bindable var vm: TimeTrackerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Time Tracker")
                    .font(.headline)
                Spacer()
                Text(HoursFormatter.signedBalance(vm.totalBalance))
                    .font(.system(.caption, design: .monospaced, weight: .bold))
                    .foregroundStyle(Color.balanceColor(for: vm.totalBalance))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background {
                        Capsule()
                            .fill(Color.balanceColor(for: vm.totalBalance).opacity(0.12))
                    }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(vm.timerIsRunning ? .green : .secondary.opacity(0.4))
                        .frame(width: 8, height: 8)
                    Text(vm.timerIsRunning ? "Running" : "Stopped")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(vm.timerDisplay)
                    .font(.system(size: 28, weight: .medium, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .center)

                if vm.timerIsRunning {
                    Text(vm.timerStatusText)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                Button(action: vm.toggleTimer) {
                    HStack(spacing: 4) {
                        Image(systemName: vm.timerIsRunning ? "stop.fill" : "play.fill")
                            .font(.caption2)
                        Text(vm.timerIsRunning ? "Stop" : "Start")
                    }
                    .frame(maxWidth: .infinity)
                }
                .controlSize(.regular)
                .buttonStyle(.borderedProminent)
                .tint(vm.timerIsRunning ? .red : .accentColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            todaySection
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

            Divider()

            HStack {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.secondary)
                .font(.caption)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(width: 260)
    }

    private var todaySection: some View {
        let todayStr = DateFormatter.isoDate.string(from: .now)
        let todayHours = vm.entries
            .filter { $0.dateString == todayStr && !$0.isOffDay }
            .reduce(0.0) { $0 + $1.durationHours }

        return VStack(alignment: .leading, spacing: 6) {
            Text("Today")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Text(HoursFormatter.duration(todayHours))
                    .font(.system(.body, design: .rounded, weight: .semibold))
                Text("/ \(HoursFormatter.rounded(vm.settings.dailyTargetHours))")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            ProgressView(value: min(todayHours / vm.settings.dailyTargetHours, 1.0))
                .tint(todayHours >= vm.settings.dailyTargetHours ? .balancePositive : .accentColor)
        }
    }
}
