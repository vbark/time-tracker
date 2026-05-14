import SwiftUI

/// Persistent app settings backed by UserDefaults via @AppStorage.
/// Used inside @Observable classes with @ObservationIgnored to avoid macro conflicts.
@Observable
@MainActor
final class AppSettings {
    @ObservationIgnored @AppStorage("dailyTargetHours") var dailyTargetHours: Double = 8.0
    @ObservationIgnored @AppStorage("csvFilePath") var csvFilePath: String = ""
    @ObservationIgnored @AppStorage("showMenuBarExtra") var showMenuBarExtra: Bool = true

    /// Weekly target derived from daily target (Mon-Fri)
    var weeklyTargetHours: Double { dailyTargetHours * 5 }

    /// Resolved primary CSV URL. Falls back to iCloud Drive path, then local app support.
    var resolvedCSVURL: URL {
        if !csvFilePath.isEmpty {
            return URL(fileURLWithPath: csvFilePath)
        }
        return Self.defaultiCloudURL ?? Self.localBackupURL
    }

    // MARK: - Default Paths

    /// iCloud Drive location: ~/Library/Mobile Documents/com~apple~CloudDocs/TimeTracker/
    static var defaultiCloudURL: URL? {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let iCloudDir = home
            .appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs/TimeTracker")
        return iCloudDir.appendingPathComponent("time_log.csv")
    }

    /// Local backup: ~/Library/Application Support/TimeTracker/
    static var localBackupURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("TimeTracker")
        return dir.appendingPathComponent("time_log_backup.csv")
    }
}
