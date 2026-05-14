import Foundation

/// Coordinates reading/writing between iCloud Drive primary file and local backup.
/// Mirrors the Python app's dual-storage pattern: always write to both, load from newest.
@Observable
@MainActor
final class StorageService {
    private(set) var statusMessage = "Initializing..."
    private(set) var hasWarning = false

    private let settings: AppSettings

    init(settings: AppSettings) {
        self.settings = settings
    }

    // MARK: - Paths

    var primaryURL: URL { settings.resolvedCSVURL }
    var backupURL: URL { AppSettings.localBackupURL }

    // MARK: - Loading

    /// Load entries from the best available source (newest of primary/backup).
    func loadEntries() -> [TimeEntry] {
        ensureDirectories()

        let candidates: [(url: URL, mod: Date)] = [primaryURL, backupURL].compactMap { url in
            guard FileManager.default.fileExists(atPath: url.path) else { return nil }
            let attrs = try? FileManager.default.attributesOfItem(atPath: url.path)
            let mod = attrs?[.modificationDate] as? Date ?? .distantPast
            return (url, mod)
        }

        // Pick most recently modified file
        guard let best = candidates.max(by: { $0.mod < $1.mod }) else {
            statusMessage = "No data file found. Add an entry to get started."
            hasWarning = false
            return []
        }

        do {
            let entries = try CSVService.readEntries(from: best.url)

            // Sync to the other file
            if best.url == primaryURL && primaryURL != backupURL {
                try? CSVService.writeEntries(entries, to: backupURL)
                statusMessage = "Loaded from primary. Backup synced."
            } else if best.url == backupURL && primaryURL != backupURL {
                statusMessage = "Loaded from backup (primary unavailable or older)."
                hasWarning = true
            } else {
                statusMessage = "Using local storage."
            }

            hasWarning = false
            return entries
        } catch {
            statusMessage = "Failed to read data: \(error.localizedDescription)"
            hasWarning = true
            return []
        }
    }

    /// Persist entries to both primary and backup locations.
    /// Returns true if at least one write succeeded.
    @discardableResult
    func saveEntries(_ entries: [TimeEntry]) -> Bool {
        var primaryOK = true
        var backupOK = true

        do {
            try CSVService.writeEntries(entries, to: primaryURL)
        } catch {
            primaryOK = false
        }

        if primaryURL != backupURL {
            do {
                try CSVService.writeEntries(entries, to: backupURL)
            } catch {
                backupOK = false
            }
        }

        if !primaryOK && !backupOK {
            statusMessage = "Failed to save to both locations."
            hasWarning = true
            return false
        }
        if !primaryOK {
            statusMessage = "Primary unavailable. Saved to backup only."
            hasWarning = true
            return true
        }
        if !backupOK {
            statusMessage = "Saved to primary. Backup sync failed."
            hasWarning = true
            return true
        }

        if primaryURL == backupURL {
            statusMessage = "Using local storage."
        } else {
            statusMessage = "Synced to primary and backup."
        }
        hasWarning = false
        return true
    }

    // MARK: - File Management

    /// Update primary file path and reload.
    func setPrimaryPath(_ path: String) {
        settings.csvFilePath = path
    }

    /// Reset to default iCloud Drive path.
    func resetToDefault() {
        settings.csvFilePath = ""
    }

    // MARK: - Private

    private func ensureDirectories() {
        let fm = FileManager.default
        for url in [primaryURL, backupURL] {
            let dir = url.deletingLastPathComponent()
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
    }
}
