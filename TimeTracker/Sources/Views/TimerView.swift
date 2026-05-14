import SwiftUI

/// Live timer card with large elapsed display and start/stop button.
struct TimerView: View {
    let vm: TimeTrackerViewModel

    var body: some View {
        GroupBox {
            VStack(spacing: 12) {
                headerLabel
                timerDisplay
                statusLabel
                toggleButton
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        } label: {
            Label("Timer", systemImage: "timer")
                .font(.headline)
        }
    }

    private var headerLabel: some View {
        EmptyView()
    }

    private var timerDisplay: some View {
        Text(vm.timerDisplay)
            .font(.system(size: 48, weight: .bold, design: .monospaced))
            .contentTransition(.numericText())
            .animation(.default, value: vm.timerDisplay)
    }

    private var statusLabel: some View {
        Text(vm.timerStatusText)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }

    private var toggleButton: some View {
        Button(action: vm.toggleTimer) {
            HStack {
                Image(systemName: vm.timerIsRunning ? "stop.fill" : "play.fill")
                Text(vm.timerIsRunning ? "Stop Timer" : "Start Timer")
            }
            .frame(maxWidth: 200)
        }
        .controlSize(.large)
        .buttonStyle(.borderedProminent)
        .tint(vm.timerIsRunning ? .red : .green)
        .keyboardShortcut("t", modifiers: .command)
    }
}
