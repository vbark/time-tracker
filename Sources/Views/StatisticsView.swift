import SwiftUI

struct StatisticsView: View {
    let vm: TimeTrackerViewModel

    var body: some View {
        VStack(spacing: 0) {
            heroBalance
                .padding(.bottom, 16)

            VStack(spacing: 12) {
                statsSection(title: "Day") {
                    StatRow(label: "Worked", value: HoursFormatter.duration(vm.dayTotalHours), valueColor: .balancePositive)
                    StatRow(label: "Balance", value: HoursFormatter.signedBalance(vm.dayBalance), valueColor: .balanceColor(for: vm.dayBalance))
                }

                statsSection(title: "Week") {
                    StatRow(label: "Worked", value: HoursFormatter.duration(vm.weekHours), valueColor: .balancePositive)
                    StatRow(
                        label: "Expected",
                        value: "\(HoursFormatter.rounded(Double(vm.weekDays) * vm.settings.dailyTargetHours)) / \(HoursFormatter.rounded(vm.settings.weeklyTargetHours))",
                        valueColor: .secondary
                    )
                    StatRow(label: "Balance", value: HoursFormatter.signedBalance(vm.weekBalance), valueColor: .balanceColor(for: vm.weekBalance))
                }

                statsSection(title: "Month") {
                    StatRow(label: "Worked", value: HoursFormatter.duration(vm.monthHours), valueColor: .balancePositive)
                    StatRow(
                        label: "Expected",
                        value: "\(HoursFormatter.rounded(Double(vm.monthDays) * vm.settings.dailyTargetHours)) / \(HoursFormatter.rounded(Double(vm.monthWeekdays) * vm.settings.dailyTargetHours))",
                        valueColor: .secondary
                    )
                    StatRow(label: "Balance", value: HoursFormatter.signedBalance(vm.monthBalance), valueColor: .balanceColor(for: vm.monthBalance))
                }

                statsSection(title: "Overall") {
                    StatRow(label: "Worked", value: HoursFormatter.duration(vm.totalHours), valueColor: .balancePositive)
                    StatRow(label: "Avg Daily", value: HoursFormatter.duration(vm.averageDailyHours), valueColor: .primary)
                    StatRow(label: "Balance", value: HoursFormatter.signedBalance(vm.totalBalance), valueColor: .balanceColor(for: vm.totalBalance))
                    StatRow(label: "Days", value: "\(vm.totalDays)", valueColor: .accentBlue)
                }
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.cardBackground)
                .stroke(Color.cardBorder.opacity(0.7), lineWidth: 1)
                .shadow(color: .black.opacity(0.10), radius: 14, y: 6)
        }
    }

    private var heroBalance: some View {
        VStack(spacing: 4) {
            Text("Overall Balance")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .textCase(.uppercase)
            Text(HoursFormatter.signedBalance(vm.totalBalance))
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.balanceColor(for: vm.totalBalance))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private func statsSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.tertiary)
                .textCase(.uppercase)
            content()
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.secondaryCardBackground)
        }
    }
}
