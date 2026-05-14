import SwiftUI

extension Color {
    static let balancePositive = Color(light: .init(red: 0.20, green: 0.60, blue: 0.35),
                                       dark: .init(red: 0.30, green: 0.78, blue: 0.45))
    static let balanceNegative = Color(light: .init(red: 0.82, green: 0.22, blue: 0.22),
                                       dark: .init(red: 0.94, green: 0.35, blue: 0.35))
    static let warningOrange = Color(light: .init(red: 0.85, green: 0.50, blue: 0.08),
                                     dark: .init(red: 0.96, green: 0.65, blue: 0.12))
    static let accentBlue = Color(light: .init(red: 0.20, green: 0.45, blue: 0.90),
                                  dark: .init(red: 0.35, green: 0.58, blue: 0.98))
    static let accentPurple = Color.accentColor
    static let accentPink = Color(light: .init(red: 0.86, green: 0.17, blue: 0.47),
                                  dark: .init(red: 0.93, green: 0.29, blue: 0.60))

    static let calendarWork = balancePositive
    static let calendarOff = balanceNegative
    static let calendarToday = warningOrange
    static let calendarSelected = accentPurple

    static let cardBackground = Color(light: .init(white: 1.0), dark: .init(white: 0.14))
    static let cardBorder = Color(light: .init(white: 0.88), dark: .init(white: 0.24))
    static let subtleBackground = Color(light: .init(white: 0.96), dark: .init(white: 0.10))

    init(light: Color, dark: Color) {
        self.init(nsColor: NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            return isDark ? NSColor(dark) : NSColor(light)
        })
    }

    static func balanceColor(for value: Double) -> Color {
        value >= 0 ? .balancePositive : .balanceNegative
    }
}
