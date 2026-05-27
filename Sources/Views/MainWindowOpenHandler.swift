import SwiftUI

/// Lives in MenuBarExtra (always mounted) so `openWindow` works after main window closed.
struct MainWindowOpenHandler: View {
    let openWindow: OpenWindowAction

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .onReceive(NotificationCenter.default.publisher(for: .requestOpenMainWindow)) { _ in
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: AppWindowID.main)
            }
    }
}
