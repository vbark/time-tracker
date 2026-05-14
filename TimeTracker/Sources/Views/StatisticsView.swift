import SwiftUI

/// Statistics panel: hero balance + day/week/month/overall sections.
/// All values pre-computed in ViewModel to keep body trivial.
struct StatisticsView: View {
    let vm: TimeTrackerViewModel

    var body: some View {
        GroupBox {
            VStack(spacing: 12) {
                heroBalance
                Divider()
                selectedDaySection
                Divider()
                selectedWeekSection
                Divider()
                selectedMonthSection
                Divider()
                overallSection
            }
            .padding(.vertical, 4)
        } label: {
            Label("Statistics", systemImage: "chart.bar")
                .font(.headline)
        }
    }

    // MARK: - Hero Balance

    private var heroBalance: some View {
        VStack(spacing: 4) {
            Text("Balance")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(HoursFormatter.signedBalance(vm.totalBalance))
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.balanceColor(for: vm.totalBalance))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Sections

    private var selectedDaySection: some View {
        VStack(alignment: .leading, spacing: 4) {
            SectionHeader(title: "Selected Day")
            StatRow(label: "Worked", value: HoursFormatter.duration(vm.dayTotalHours), valueColor: .balancePositive)
            StatRow(label: "Balance", value: HoursFormatter.signedBalance(vm.dayBalance), valueColor: .balanceColor(for: vm.dayBalance))
        }
    }

    private var selectedWeekSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            SectionHeader(title: "Selected Week")
            StatRow(label: "Worked", value: HoursFormatter.duration(vm.weekHours), valueColor: .balancePositive)
            StatRow(
                label: "Expected",
                value: "\(HoursFormatter.rounded(Double(vm.weekDays) * vm.settings.dailyTargetHours)) / \(HoursFormatter.rounded(vm.settings.weeklyTargetHours))",
                valueColor: .secondary
            )
            StatRow(label: "Balance", value: HoursFormatter.signedBalance(vm.weekBalance), valueColor: .balanceColor(for: vm.weekBalance))
            StatRow(label: "Days", value: "\(vm.weekDays)", valueColor: .accentBlue)
        }
    }

    private var selectedMonthSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            SectionHeader(title: "Selected Month")
            StatRow(label: "Worked", value: HoursFormatter.duration(vm.monthHours), valueColor: .balancePositive)
            StatRow(
                label: "Expected",
                value: "\(HoursFormatter.rounded(Double(vm.monthDays) * vm.settings.dailyTargetHours)) / \(HoursFormatter.rounded(Double(vm.monthWeekdays) * vm.settings.dailyTargetHours))",
                valueColor: .secondary
            )
            StatRow(label: "Balance", value: HoursFormatter.signedBalance(vm.monthBalance), valueColor: .balanceColor(for: vm.monthBalance))
            StatRow(label: "Days", value: "\(vm.monthDays)", valueColor: .accentBlue)
        }
    }

    private var overallSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            SectionHeader(title: "Overall")
            StatRow(label: "Worked", value: HoursFormatter.duration(vm.totalHours), valueColor: .balancePositive)
            StatRow(label: "Expected", value: HoursFormatter.rounded(Double(vm.totalDays) * vm.settings.dailyTargetHours), valueColor: .secondary)
            StatRow(label: "Avg Daily", value: HoursFormatter.duration(vm.averageDailyHours), valueColor: .balancePositive)
            StatRow(label: "Balance", value: HoursFormatter.signedBalance(vm.totalBalance), valueColor: .balanceColor(for: vm.totalBalance))
            StatRow(label: "Days", value: "\(vm.totalDays)", valueColor: .accentBlue)
        }
    }
}

// MARK: - Section Header

private struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
    }
}
