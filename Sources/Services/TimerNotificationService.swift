import Foundation
import UserNotifications

@Observable
@MainActor
final class TimerNotificationService: NSObject, @preconcurrency UNUserNotificationCenterDelegate {
    private enum Identifier {
        static let category = "timerReminder"
        static let start = "startTimer"
        static let snooze = "snoozeTimer"
        static let reminder = "timerReminderRequest"
    }

    private let center = UNUserNotificationCenter.current()
    private var startAction: (@MainActor () -> Void)?
    private var snoozeAction: (@MainActor () -> Void)?
    private(set) var authorizationStatusText = "Checking..."
    private(set) var isAuthorized = false

    func configure(start: @escaping @MainActor () -> Void, snooze: @escaping @MainActor () -> Void) {
        startAction = start
        snoozeAction = snooze
        center.delegate = self

        let startAction = UNNotificationAction(
            identifier: Identifier.start,
            title: "Start Timer",
            options: []
        )
        let snoozeAction = UNNotificationAction(
            identifier: Identifier.snooze,
            title: "Not Now",
            options: []
        )
        let category = UNNotificationCategory(
            identifier: Identifier.category,
            actions: [startAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        center.setNotificationCategories([category])

        requestAuthorization()
    }

    @discardableResult
    func showReminder() -> Bool {
        guard isAuthorized else {
            requestAuthorization()
            return false
        }

        let content = UNMutableNotificationContent()
        content.title = "Start tracking?"
        content.body = "You are active, but the timer is not running."
        content.sound = .default
        content.categoryIdentifier = Identifier.category

        let request = UNNotificationRequest(
            identifier: Identifier.reminder,
            content: content,
            trigger: nil
        )
        center.add(request)
        return true
    }

    func sendTestReminder() {
        showReminder()
    }

    func requestAuthorization() {
        Task {
            let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
            isAuthorized = granted
            await refreshAuthorizationStatus()
        }
    }

    func refreshAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized:
            authorizationStatusText = "Notifications enabled"
            isAuthorized = true
        case .provisional:
            authorizationStatusText = "Notifications enabled quietly"
            isAuthorized = true
        case .ephemeral:
            authorizationStatusText = "Notifications enabled temporarily"
            isAuthorized = true
        case .denied:
            authorizationStatusText = "Notifications disabled in System Settings"
            isAuthorized = false
        case .notDetermined:
            authorizationStatusText = "Permission not requested"
            isAuthorized = false
        @unknown default:
            authorizationStatusText = "Notification status unknown"
            isAuthorized = false
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        switch response.actionIdentifier {
        case Identifier.start, UNNotificationDefaultActionIdentifier:
            startAction?()
        case Identifier.snooze, UNNotificationDismissActionIdentifier:
            snoozeAction?()
        default:
            break
        }
        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
