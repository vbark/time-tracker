import SwiftUI

/// Compact summary bar showing selected day's total hours, balance, entry count, and status.
struct DaySummaryView: View {
    let vm: TimeTrackerViewModel

    var body: some View {
        GroupBox {
            HStack(spacing: 24) {
                summaryItem(label: "Total", value: totalText, color: totalColor)
                summaryItem(label: "Balance", value: balanceText, color: balanceColor)
                summaryItem(label: "Entries", value: "\(workEntryCount)", color: .accentBlue)
                Spacer()
                statusBadge
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Summary Items

    private func summaryItem(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(color)
        }
    }

    // MARK: - Computed Display Values

    private var totalText: String {
        vm.dayIsAllOff ? "Off Day" : HoursFormatter.duration(vm.dayTotalHours)
    }

    private var totalColor: Color {
        vm.dayIsAllOff ? .balanceNegative : .accentPurple
    }

    private var balanceText: String {
        if vm.dayIsAllOff || vm.selectedDayEntries.isEmpty { return "—" }
        return HoursFormatter.signedBalance(vm.dayBalance)
    }

    private var balanceColor: Color {
        if vm.dayIsAllOff || vm.selectedDayEntries.isEmpty { return .secondary }
        return .balanceColor(for: vm.dayBalance)
    }

    private var workEntryCount: Int {
        vm.selectedDayEntries.filter { !$0.isOffDay }.count
    }

    private var statusBadge: some View {
        Text(statusText)
            .font(.callout)
            .foregroundStyle(statusColor)
    }

    private var statusText: String {
        if vm.dayIsAllOff { return "Day Off" }
        if vm.selectedDayEntries.isEmpty { return "No entries" }
        if vm.dayBalance > 0 { return "Overtime!" }
        if vm.dayBalance == 0 { return "Target met" }
        let remaining = vm.settings.dailyTargetHours - vm.dayTotalHours
        let h = Int(remaining)
        let m = Int((remaining - Double(h)) * 60)
        return "\(h)h \(m)m to go"
    }

    private var statusColor: Color {
        if vm.dayIsAllOff { return .balanceNegative }
        if vm.selectedDayEntries.isEmpty { return .secondary }
        if vm.dayBalance >= 0 { return .balancePositive }
        return .warningOrange
    }
}
