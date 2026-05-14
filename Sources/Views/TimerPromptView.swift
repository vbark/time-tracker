import SwiftUI

struct TimerPromptOverlay: View {
    let vm: TimeTrackerViewModel
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.black.opacity(appeared ? 0.3 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            VStack(spacing: 20) {
                Image(systemName: "clock.badge.questionmark")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.accentColor)
                    .symbolRenderingMode(.hierarchical)

                VStack(spacing: 6) {
                    Text("Start Tracking?")
                        .font(.title2.weight(.semibold))
                    Text("You've been active for a while without tracking time.\nWould you like to start the timer?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 12) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Not Now")
                            .frame(width: 100)
                    }
                    .controlSize(.large)
                    .buttonStyle(.bordered)

                    Button {
                        vm.startTimer()
                        vm.activityMonitor.userDismissed()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "play.fill")
                                .font(.caption)
                            Text("Start Timer")
                        }
                        .frame(width: 120)
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
                }

                Button {
                    decline()
                } label: {
                    Text("Don't remind me today")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
            .padding(32)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
            }
            .frame(maxWidth: 400)
            .scaleEffect(appeared ? 1 : 0.9)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.25)) {
                appeared = true
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeIn(duration: 0.15)) {
            appeared = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            vm.activityMonitor.userDismissed()
        }
    }

    private func decline() {
        withAnimation(.easeIn(duration: 0.15)) {
            appeared = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            vm.activityMonitor.userDeclined()
        }
    }
}
