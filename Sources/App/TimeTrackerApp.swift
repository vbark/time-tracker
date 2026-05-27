import SwiftUI

@main
struct TimeTrackerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var vm = TimeTrackerViewModel()

    var body: some Scene {
        Window("Time Tracker", id: AppWindowID.main) {
            MainView(vm: vm)
                .timeTrackerWindowStyle()
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
                .timeTrackerWindowStyle()
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
    func timeTrackerWindowStyle() -> some View {
        background(WindowConfigurator())
    }
}

private struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            configure(window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let window = nsView.window else { return }
        configure(window)
    }

    private func configure(_ window: NSWindow) {
        AppWindowController.configureMainWindow(window)
    }
}
