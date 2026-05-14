import SwiftUI

/// Semantic color palette that adapts to light/dark mode automatically.
/// Uses SwiftUI adaptive colors where possible, custom pairs where needed.
extension Color {
    // MARK: - Brand Accents
    static let accentPurple = Color("AccentColor")
    static let accentPink = Color(light: .init(red: 0.86, green: 0.17, blue: 0.47),
                                  dark: .init(red: 0.93, green: 0.29, blue: 0.60))

    // MARK: - Semantic Colors
    static let balancePositive = Color(light: .init(red: 0.09, green: 0.64, blue: 0.29),
                                       dark: .init(red: 0.13, green: 0.77, blue: 0.37))
    static let balanceNegative = Color(light: .init(red: 0.86, green: 0.15, blue: 0.15),
                                       dark: .init(red: 0.94, green: 0.27, blue: 0.27))
    static let warningOrange = Color(light: .init(red: 0.85, green: 0.47, blue: 0.02),
                                     dark: .init(red: 0.96, green: 0.62, blue: 0.04))
    static let accentBlue = Color(light: .init(red: 0.15, green: 0.39, blue: 0.92),
                                  dark: .init(red: 0.23, green: 0.51, blue: 0.96))

    // MARK: - Calendar Day Colors
    static let calendarWork = balancePositive
    static let calendarOff = balanceNegative
    static let calendarToday = warningOrange
    static let calendarSelected = accentPurple

    // MARK: - Adaptive Initializer

    /// Create a color that adapts between light and dark mode
    init(light: Color, dark: Color) {
        self.init(nsColor: NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            return isDark ? NSColor(dark) : NSColor(light)
        })
    }
}

/// Balance color helper
extension Color {
    static func balanceColor(for value: Double) -> Color {
        value >= 0 ? .balancePositive : .balanceNegative
    }
}
