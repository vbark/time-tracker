import SwiftUI

@Observable
@MainActor
final class AppSettings {
    @ObservationIgnored @AppStorage("dailyTargetHours") var dailyTargetHours: Double = 8.0
    @ObservationIgnored @AppStorage("csvFilePath") var csvFilePath: String = ""
    @ObservationIgnored @AppStorage("showMenuBarExtra") var showMenuBarExtra: Bool = true

    var weeklyTargetHours: Double { dailyTargetHours * 5 }

    var resolvedCSVURL: URL {
        if !csvFilePath.isEmpty {
            return URL(fileURLWithPath: csvFilePath)
        }
        return Self.defaultiCloudURL ?? Self.localBackupURL
    }

    static var defaultiCloudURL: URL? {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let iCloudDir = home
            .appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs/TimeTracker")
        return iCloudDir.appendingPathComponent("time_log.csv")
    }

    static var localBackupURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("TimeTracker")
        return dir.appendingPathComponent("time_log_backup.csv")
    }
}
