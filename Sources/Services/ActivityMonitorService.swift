import Foundation
import AppKit
import IOKit

@Observable
@MainActor
final class ActivityMonitorService {
    private(set) var shouldShowPrompt = false

    private var checkTimer: Timer?
    private var lastDeclineTime: Date?
    private var lastPromptDismissTime: Date?
    private var isMonitoring = false

    private var isTimerRunning: () -> Bool = { false }
    private var settings: AppSettings?

    func startMonitoring(settings: AppSettings, isTimerRunning: @escaping @Sendable () -> Bool) {
        guard !isMonitoring else { return }
        self.settings = settings
        self.isTimerRunning = isTimerRunning
        isMonitoring = true

        let wsnc = NSWorkspace.shared.notificationCenter
        wsnc.addObserver(forName: NSWorkspace.screensDidWakeNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in
                self?.onUserBecameActive()
            }
        }
        wsnc.addObserver(forName: NSWorkspace.sessionDidBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in
                self?.onUserBecameActive()
            }
        }

        startPeriodicCheck()
    }

    func stopMonitoring() {
        isMonitoring = false
        checkTimer?.invalidate()
        checkTimer = nil
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    func userDeclined() {
        shouldShowPrompt = false
        lastDeclineTime = Date()
    }

    func userDismissed() {
        shouldShowPrompt = false
        lastPromptDismissTime = Date()
    }

    // MARK: - Private

    private func onUserBecameActive() {
        guard isMonitoring, !isTimerRunning(), shouldRemind() else { return }
        scheduleDelayedPrompt()
    }

    private func startPeriodicCheck() {
        checkTimer?.invalidate()
        checkTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.periodicCheck()
            }
        }
    }

    private func periodicCheck() {
        guard isMonitoring else { return }
        guard let settings, settings.reminderEnabled else { return }
        guard !isTimerRunning() else {
            shouldShowPrompt = false
            return
        }
        guard !shouldShowPrompt else { return }
        guard shouldRemind() else { return }

        let idleSeconds = systemIdleTime()
        let delaySeconds = TimeInterval(settings.reminderDelayMinutes * 60)

        if idleSeconds < delaySeconds && !isWeekend() {
            shouldShowPrompt = true
        }
    }

    private func scheduleDelayedPrompt() {
        guard let settings else { return }
        let delay = TimeInterval(settings.reminderDelayMinutes * 60)
        Task {
            try? await Task.sleep(for: .seconds(delay))
            guard isMonitoring, !isTimerRunning(), shouldRemind() else { return }
            shouldShowPrompt = true
        }
    }

    private func shouldRemind() -> Bool {
        guard let settings, settings.reminderEnabled else { return false }
        if isWeekend() { return false }

        let snoozeInterval = TimeInterval(settings.reminderSnoozeMinutes * 60)
        if let decline = lastDeclineTime, Date().timeIntervalSince(decline) < snoozeInterval {
            return false
        }
        if let dismiss = lastPromptDismissTime, Date().timeIntervalSince(dismiss) < snoozeInterval {
            return false
        }
        return true
    }

    private func isWeekend() -> Bool {
        Calendar.current.isDateInWeekend(Date())
    }

    private nonisolated func systemIdleTime() -> TimeInterval {
        var iterator: io_iterator_t = 0
        defer { IOObjectRelease(iterator) }

        let result = IOServiceGetMatchingServices(
            kIOMainPortDefault,
            IOServiceMatching("IOHIDSystem"),
            &iterator
        )
        guard result == KERN_SUCCESS else { return 0 }

        let entry = IOIteratorNext(iterator)
        defer { IOObjectRelease(entry) }
        guard entry != 0 else { return 0 }

        var unmanagedDict: Unmanaged<CFMutableDictionary>?
        guard IORegistryEntryCreateCFProperties(entry, &unmanagedDict, kCFAllocatorDefault, 0) == KERN_SUCCESS,
              let dict = unmanagedDict?.takeRetainedValue() as? [String: Any],
              let idle = dict["HIDIdleTime"] as? Int64 else { return 0 }

        return TimeInterval(idle) / 1_000_000_000
    }
}
