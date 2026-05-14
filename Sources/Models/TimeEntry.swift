import Foundation

/// A single time-tracking entry, compatible with the legacy CSV format.
/// CSV columns: date, start_time, end_time, duration, is_off_day, is_overtime_taken, note
struct TimeEntry: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var date: Date
    var startTime: String          // "HH:mm" format
    var endTime: String            // "HH:mm" format
    var duration: String           // "HH:mm" computed duration
    var isOffDay: Bool
    var isOvertimeTaken: Bool
    var note: String

    init(
        id: UUID = UUID(),
        date: Date,
        startTime: String,
        endTime: String,
        duration: String? = nil,
        isOffDay: Bool = false,
        isOvertimeTaken: Bool = false,
        note: String = ""
    ) {
        self.id = id
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration ?? Self.calculateDuration(start: startTime, end: endTime, isOffDay: isOffDay)
        self.isOffDay = isOffDay
        self.isOvertimeTaken = isOvertimeTaken
        self.note = note
    }

    // MARK: - Duration Calculation

    /// Compute "HH:mm" duration from start/end time strings. Off days always return "00:00".
    static func calculateDuration(start: String, end: String, isOffDay: Bool) -> String {
        if isOffDay { return "00:00" }

        let formatter = DateFormatter.hourMinute
        guard let startDate = formatter.date(from: start),
              var endDate = formatter.date(from: end) else {
            return "00:00"
        }

        // Handle crossing midnight
        if endDate < startDate {
            endDate = endDate.addingTimeInterval(24 * 3600)
        }

        let seconds = Int(endDate.timeIntervalSince(startDate))
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }

    /// Duration in decimal hours (e.g. "07:30" -> 7.5)
    var durationHours: Double {
        let parts = duration.split(separator: ":")
        guard parts.count == 2,
              let h = Double(parts[0]),
              let m = Double(parts[1]) else { return 0 }
        return h + m / 60.0
    }

    /// Date formatted as "YYYY-MM-dd" for CSV and grouping
    var dateString: String {
        DateFormatter.isoDate.string(from: date)
    }

    // MARK: - Display Helpers

    var timeRangeDisplay: String {
        "\(startTime) - \(endTime)"
    }

    var typeDisplay: String {
        isOffDay ? "Off Day" : "Work"
    }
}
