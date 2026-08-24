import SwiftUI

struct MenuBarView: View {
    @Bindable var vm: TimeTrackerViewModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 10)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(vm.timerIsRunning ? Color.balancePositive : .secondary.opacity(0.4))
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
                .tint(vm.timerIsRunning ? Color.balanceNegative : Color.accentPurple)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            todaySection
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
        }
        .frame(width: 260)
        .fixedSize(horizontal: false, vertical: true)
        .background(Color.appBackground)
        .background(MainWindowOpenHandler(openWindow: openWindow))
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 8) {
            Button {
                AppWindowController.openMainWindow()
            } label: {
                Text("Time Tracker")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens the main Time Tracker window")

            Spacer(minLength: 4)

            Text(HoursFormatter.signedBalance(vm.totalBalance))
                .font(.system(.caption, design: .monospaced, weight: .bold))
                .foregroundStyle(Color.balanceColor(for: vm.totalBalance))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background {
                    Capsule()
                        .fill(Color.balanceColor(for: vm.totalBalance).opacity(0.12))
                }
                .layoutPriority(1)

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "power")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
                    .background {
                        Circle()
                            .fill(Color.secondary.opacity(0.12))
                    }
            }
            .buttonStyle(.plain)
            .help("Quit Time Tracker")
            .accessibilityLabel("Quit")
        }
    }

    private var todaySection: some View {
        let todayStr = DateFormatter.isoDate.string(from: .now)
        let todayHours = vm.entries
            .filter { $0.dateString == todayStr && !$0.isOffDay }
            .reduce(0.0) { $0 + $1.effectiveDurationHours }
        let todayOffCredit = vm.entries
            .filter { $0.dateString == todayStr && $0.isOffDay }
            .reduce(0.0) { $0 + $1.effectiveDurationHours }
        let todayHasOff = vm.entries.contains { $0.dateString == todayStr && $0.isOffDay }
        let target = vm.settings.dailyTargetHours
        let effectiveTarget = todayHasOff ? max(0, target - todayOffCredit) : target
        let progress = effectiveTarget > 0 ? min(todayHours / effectiveTarget, 1.0) : 0

        return VStack(alignment: .leading, spacing: 6) {
            Text("Today")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Text(HoursFormatter.duration(todayHours))
                    .font(.system(.body, design: .rounded, weight: .semibold))
                if todayHasOff && effectiveTarget < target {
                    Text("/ \(HoursFormatter.rounded(effectiveTarget))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                } else {
                    Text("/ \(HoursFormatter.rounded(target))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            ProgressView(value: progress)
                .tint(todayHours >= effectiveTarget && effectiveTarget > 0 ? .balancePositive : .accentPurple)
        }
    }
}
