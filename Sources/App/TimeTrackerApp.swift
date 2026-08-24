import SwiftUI

@main
struct TimeTrackerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var vm = TimeTrackerViewModel()

    var body: some Scene {
        Window("Time Tracker", id: AppWindowID.main) {
            MainView(vm: vm)
                .timeTrackerWindowStyle(applyDefaultSize: true)
                .tint(Color.accentPurple)
        }
        .defaultSize(
            width: AppWindowController.defaultSize.width,
            height: AppWindowController.defaultSize.height
        )
        .windowResizability(.contentMinSize)
        .windowToolbarStyle(.unified(showsTitle: false))
        .commands {
            appCommands
        }

        MenuBarExtra {
            MenuBarView(vm: vm)
                .tint(Color.accentPurple)
        } label: {
            if vm.timerIsRunning {
                Label(vm.timerDisplay, systemImage: "clock.fill")
            } else {
                Label("Time Tracker", systemImage: "clock")
            }
        }
        .menuBarExtraStyle(.window)

        Settings {
            StorageSettingsView(vm: vm)
                .timeTrackerWindowStyle(applyDefaultSize: false)
                .tint(Color.accentPurple)
        }
    }

    @CommandsBuilder
    private var appCommands: some Commands {
        CommandMenu("Tracker") {
            Button(vm.timerIsRunning ? "Stop Timer" : "Start Timer") {
                vm.toggleTimer()
            }
            .keyboardShortcut("t", modifiers: .command)

            Divider()

            Button("Go to Today") {
                vm.goToToday()
            }
            .keyboardShortcut(.escape, modifiers: [])

            Button("Refresh Data") {
                vm.refreshData()
            }
            .keyboardShortcut("r", modifiers: .command)
        }
    }
}

private extension View {
    func timeTrackerWindowStyle(applyDefaultSize: Bool) -> some View {
        background(WindowConfigurator(applyDefaultSize: applyDefaultSize))
    }
}

/// Applies window chrome without driving a SwiftUI layout loop.
/// Default size is applied once in `viewDidMoveToWindow`, never from a
/// repeating `updateNSView` → `setContentSize` cycle.
private struct WindowConfigurator: NSViewRepresentable {
    var applyDefaultSize: Bool

    func makeNSView(context: Context) -> WindowConfigNSView {
        let view = WindowConfigNSView()
        view.applyDefaultSize = applyDefaultSize
        return view
    }

    func updateNSView(_ nsView: WindowConfigNSView, context: Context) {
        nsView.applyDefaultSize = applyDefaultSize
        nsView.applyChromeIfPossible()
    }
}

private final class WindowConfigNSView: NSView {
    var applyDefaultSize = false
    private var didApplyDefaultSize = false

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        applyChromeIfPossible()
        applyDefaultSizeIfNeeded()
    }

    func applyChromeIfPossible() {
        guard let window else { return }
        AppWindowController.configureWindowChrome(window)
        applyDefaultSizeIfNeeded()
    }

    private func applyDefaultSizeIfNeeded() {
        guard applyDefaultSize, !didApplyDefaultSize, let window else { return }
        AppWindowController.applyDefaultFrameIfNeeded(to: window)
        didApplyDefaultSize = true
    }
}
