import SwiftUI

/// App entry point: main window + menu bar extra + settings scene.
/// Keyboard shortcuts are registered via Commands to appear in the menu bar automatically.
@main
struct TimeTrackerApp: App {
    @State private var vm = TimeTrackerViewModel()

    var body: some Scene {
        // MARK: - Main Window

        WindowGroup {
            MainView(vm: vm)
                .navigationTitle("Time Tracker")
        }
        .defaultSize(width: 1100, height: 720)
        .windowResizability(.contentMinSize)
        .windowToolbarStyle(.unified)
        .commands {
            appCommands
        }

        // MARK: - Menu Bar Extra (popover panel)

        MenuBarExtra("Time Tracker", systemImage: vm.timerIsRunning ? "clock.fill" : "clock") {
            MenuBarView(vm: vm)
        }
        .menuBarExtraStyle(.window)

        // MARK: - Settings (Cmd+,)

        Settings {
            StorageSettingsView(vm: vm)
        }
    }

    // MARK: - Menu Bar Commands

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
