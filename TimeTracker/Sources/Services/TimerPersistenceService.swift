import Foundation

/// Persists running timer state to UserDefaults so it survives app restarts.
/// On launch, checks if a timer was running and restores the original start time.
enum TimerPersistenceService {
    private static let isRunningKey = "timer_isRunning"
    private static let startTimeKey = "timer_startTime"

    /// Save timer state. Call on start and periodically while running.
    static func save(isRunning: Bool, startTime: Date?) {
        UserDefaults.standard.set(isRunning, forKey: isRunningKey)
        UserDefaults.standard.set(startTime, forKey: startTimeKey)
    }

    /// Restore timer state on app launch.
    /// Returns the original start time if a timer was running, nil otherwise.
    static func restore() -> Date? {
        let isRunning = UserDefaults.standard.bool(forKey: isRunningKey)
        guard isRunning else { return nil }
        return UserDefaults.standard.object(forKey: startTimeKey) as? Date
    }

    /// Clear persisted timer state. Call when timer stops.
    static func clear() {
        UserDefaults.standard.removeObject(forKey: isRunningKey)
        UserDefaults.standard.removeObject(forKey: startTimeKey)
    }
}
