import SwiftUI

struct OverallBalanceHeader: View {
    let vm: TimeTrackerViewModel

    var body: some View {
        VStack(spacing: 2) {
            Text("Overall Balance")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.tertiary)
                .textCase(.uppercase)
                .tracking(0.6)
            Text(HoursFormatter.signedBalance(vm.totalBalance))
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.balanceColor(for: vm.totalBalance))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Overall balance \(HoursFormatter.signedBalance(vm.totalBalance))")
    }
}

struct StatisticsPanelView: View {
    let vm: TimeTrackerViewModel

    var body: some View {
        VStack(spacing: 8) {
            statsSection(title: "Day") {
                StatRow(label: "Worked", value: HoursFormatter.duration(vm.dayTotalHours), valueColor: .balancePositive)
                StatRow(label: "Balance", value: HoursFormatter.signedBalance(vm.dayBalance), valueColor: .balanceColor(for: vm.dayBalance))
            }

            statsSection(title: "Week") {
                StatRow(label: "Worked", value: HoursFormatter.duration(vm.weekHours), valueColor: .balancePositive)
                StatRow(
                    label: "Expected",
                    value: "\(HoursFormatter.rounded(vm.weekExpectedHours)) / \(HoursFormatter.rounded(vm.settings.weeklyTargetHours))",
                    valueColor: .secondary
                )
                StatRow(label: "Balance", value: HoursFormatter.signedBalance(vm.weekBalance), valueColor: .balanceColor(for: vm.weekBalance))
            }

            statsSection(title: "Month") {
                StatRow(label: "Worked", value: HoursFormatter.duration(vm.monthHours), valueColor: .balancePositive)
                StatRow(
                    label: "Expected",
                    value: "\(HoursFormatter.rounded(vm.monthExpectedHours)) / \(HoursFormatter.rounded(Double(vm.monthWeekdays) * vm.settings.dailyTargetHours))",
                    valueColor: .secondary
                )
                StatRow(label: "Balance", value: HoursFormatter.signedBalance(vm.monthBalance), valueColor: .balanceColor(for: vm.monthBalance))
            }

            statsSection(title: "Overall") {
                StatRow(label: "Worked", value: HoursFormatter.duration(vm.totalHours), valueColor: .balancePositive)
                StatRow(label: "Avg Daily", value: HoursFormatter.duration(vm.averageDailyHours), valueColor: .primary)
                StatRow(
                    label: "Avg Weekly",
                    value: HoursFormatter.duration(vm.averageWeeklyHours),
                    valueColor: .primary
                )
                .accessibilityLabel("Average weekly hours, \(vm.trackingWeekCount) weeks tracked")
                StatRow(
                    label: "Avg Monthly",
                    value: HoursFormatter.duration(vm.averageMonthlyHours),
                    valueColor: .primary
                )
                .accessibilityLabel("Average monthly hours, \(vm.trackingMonthCount) months tracked")
                StatRow(label: "Balance", value: HoursFormatter.signedBalance(vm.totalBalance), valueColor: .balanceColor(for: vm.totalBalance))
                StatRow(label: "Days", value: "\(vm.totalDays)", valueColor: .accentBlue)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.cardBackground)
                .stroke(Color.cardBorder.opacity(0.7), lineWidth: 1)
                .shadow(color: .black.opacity(0.12), radius: 18, y: 8)
        }
    }

    private func statsSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.tertiary)
                .textCase(.uppercase)
                .tracking(0.6)
            content()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.cardBackground.opacity(0.7))
                .stroke(Color.cardBorder.opacity(0.45), lineWidth: 1)
        }
    }
}
