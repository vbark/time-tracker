import SwiftUI

struct TimerView: View {
    let vm: TimeTrackerViewModel

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(vm.timerIsRunning ? .green : .secondary.opacity(0.4))
                        .frame(width: 8, height: 8)
                    Text(vm.timerIsRunning ? "Running" : "Ready")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(vm.timerDisplay)
                    .font(.system(size: 56, weight: .light, design: .monospaced))
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.15), value: vm.timerDisplay)
                    .foregroundStyle(vm.timerIsRunning ? .primary : .secondary)

                if vm.timerIsRunning, let start = vm.timerStartTime {
                    Text("Since \(DateFormatter.hourMinute.string(from: start))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Button(action: vm.toggleTimer) {
                HStack(spacing: 6) {
                    Image(systemName: vm.timerIsRunning ? "stop.fill" : "play.fill")
                        .font(.system(size: 11))
                    Text(vm.timerIsRunning ? "Stop" : "Start")
                        .fontWeight(.medium)
                }
                .frame(width: 120)
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .tint(vm.timerIsRunning ? .red : .accentColor)
            .keyboardShortcut("t", modifiers: .command)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
        }
    }
}
