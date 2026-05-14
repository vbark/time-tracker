import Foundation
import ServiceManagement

@Observable
@MainActor
final class LaunchAtLoginService {
    private(set) var isEnabled = false
    private(set) var statusMessage = "Checking..."

    init() {
        refresh()
    }

    func refresh() {
        switch SMAppService.mainApp.status {
        case .enabled:
            isEnabled = true
            statusMessage = "Enabled"
        case .requiresApproval:
            isEnabled = true
            statusMessage = "Needs approval in System Settings"
        case .notRegistered:
            isEnabled = false
            statusMessage = "Disabled"
        case .notFound:
            isEnabled = false
            statusMessage = "Only available from the built app bundle"
        @unknown default:
            isEnabled = false
            statusMessage = "Unknown"
        }
    }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            refresh()
        } catch {
            refresh()
            statusMessage = error.localizedDescription
        }
    }
}
