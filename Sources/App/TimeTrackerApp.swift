import SwiftUI

@main
struct TimeTrackerApp: App {
    @State private var vm = TimeTrackerViewModel()

    var body: some Scene {
        WindowGroup {
            MainView(vm: vm)
                .timeTrackerWindowStyle()
                .tint(Color.accentPurple)
        }
        .defaultSize(width: 1060, height: 780)
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
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.backgroundColor = NSColor(Color.appChrome)
            window.isMovableByWindowBackground = true
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let window = nsView.window else { return }
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.backgroundColor = NSColor(Color.appChrome)
    }
}
