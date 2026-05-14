import Foundation

// MARK: - Reusable DateFormatters (static, never created in body)

extension DateFormatter {
    /// "yyyy-MM-dd" for CSV date column
    static let isoDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    /// "HH:mm" for CSV time columns
    static let hourMinute: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    /// "EEEE, MMMM d, yyyy" for display headers
    static let fullDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d, yyyy"
        return f
    }()

    /// "MMMM yyyy" for calendar month label
    static let monthYear: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }()
}

// MARK: - Hours Formatting Helpers

enum HoursFormatter {
    /// Decimal hours -> "+Xh Ym" or "-Xh Ym" (signed balance)
    static func signedBalance(_ hours: Double) -> String {
        let sign = hours >= 0 ? "+" : "-"
        let abs = Swift.abs(hours)
        let h = Int(abs)
        let m = Int((abs - Double(h)) * 60)
        return "\(sign)\(h)h \(m)m"
    }

    /// Decimal hours -> "Xh Ym" (unsigned duration)
    static func duration(_ hours: Double) -> String {
        let h = Int(hours)
        let m = Int((hours - Double(h)) * 60)
        return "\(h)h \(m)m"
    }

    /// Decimal hours -> "Xh" (rounded)
    static func rounded(_ hours: Double) -> String {
        "\(Int(hours.rounded()))h"
    }
}
