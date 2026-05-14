import SwiftUI

@main
struct TimeTrackerApp: App {
    @State private var vm = TimeTrackerViewModel()

    var body: some Scene {
        WindowGroup {
            MainView(vm: vm)
        }
        .defaultSize(width: 1060, height: 780)
        .windowResizability(.contentMinSize)
        .windowToolbarStyle(.unified(showsTitle: false))
        .commands {
            appCommands
        }

        MenuBarExtra {
            MenuBarView(vm: vm)
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
