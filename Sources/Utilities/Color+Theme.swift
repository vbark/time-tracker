import SwiftUI

// Catppuccin Latte (light) / Mocha (dark)
extension Color {
    // Green: Latte #40a02b / Mocha #a6e3a1
    static let balancePositive = Color(light: .init(red: 0.251, green: 0.627, blue: 0.169),
                                       dark: .init(red: 0.651, green: 0.890, blue: 0.631))
    // Red: Latte #d20f39 / Mocha #f38ba8
    static let balanceNegative = Color(light: .init(red: 0.824, green: 0.059, blue: 0.224),
                                       dark: .init(red: 0.953, green: 0.545, blue: 0.659))
    // Peach: Latte #fe640b / Mocha #fab387
    static let warningOrange = Color(light: .init(red: 0.996, green: 0.392, blue: 0.043),
                                     dark: .init(red: 0.980, green: 0.702, blue: 0.529))
    // Blue: Latte #1e66f5 / Mocha #89b4fa
    static let accentBlue = Color(light: .init(red: 0.118, green: 0.400, blue: 0.961),
                                  dark: .init(red: 0.537, green: 0.706, blue: 0.980))
    // Mauve: Latte #8839ef / Mocha #cba6f7
    static let accentPurple = Color(light: .init(red: 0.533, green: 0.224, blue: 0.937),
                                    dark: .init(red: 0.796, green: 0.651, blue: 0.969))
    // Pink: Latte #ea76cb / Mocha #f5c2e7
    static let accentPink = Color(light: .init(red: 0.918, green: 0.463, blue: 0.796),
                                  dark: .init(red: 0.961, green: 0.761, blue: 0.906))
    // Teal: Latte #179299 / Mocha #94e2d5
    static let accentTeal = Color(light: .init(red: 0.090, green: 0.573, blue: 0.600),
                                  dark: .init(red: 0.580, green: 0.886, blue: 0.835))

    // Calendar
    static let calendarWork = balancePositive
    static let calendarOff = balanceNegative
    static let calendarToday = warningOrange
    static let calendarSelected = accentPurple

    // Surfaces: Latte Base #eff1f5 / Mocha Base #1e1e2e
    static let cardBackground = Color(light: .init(red: 0.937, green: 0.945, blue: 0.961),
                                      dark: .init(red: 0.118, green: 0.118, blue: 0.180))
    // Latte Surface0 #ccd0da / Mocha Surface0 #313244
    static let cardBorder = Color(light: .init(red: 0.800, green: 0.816, blue: 0.855),
                                  dark: .init(red: 0.192, green: 0.196, blue: 0.267))
    // Latte Mantle #e6e9ef / Mocha Mantle #181825
    static let subtleBackground = Color(light: .init(red: 0.902, green: 0.914, blue: 0.937),
                                        dark: .init(red: 0.094, green: 0.094, blue: 0.145))

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
