import SwiftUI

struct DaySummaryView: View {
    let vm: TimeTrackerViewModel

    var body: some View {
        HStack(spacing: 0) {
            statPill(label: "Worked", value: totalText, color: totalColor)
            Spacer()
            statPill(label: "Balance", value: balanceText, color: balanceColor)
            Spacer()
            statPill(label: "Entries", value: "\(workEntryCount)", color: .accentBlue)
            Spacer()
            statusBadge
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.cardBackground)
                .stroke(Color.cardBorder.opacity(0.65), lineWidth: 1)
        }
    }

    private func statPill(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .textCase(.uppercase)
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(color)
        }
    }

    private var totalText: String {
        if vm.dayIsAllOff {
            return HoursFormatter.duration(vm.dayOffCreditHours)
        }
        if vm.dayHasOffDay && vm.dayTotalHours == 0 {
            return HoursFormatter.duration(vm.dayOffCreditHours)
        }
        return HoursFormatter.duration(vm.dayTotalHours)
    }

    private var totalColor: Color {
        if vm.dayIsAllOff || (vm.dayHasOffDay && vm.dayTotalHours == 0) {
            return .balanceNegative
        }
        return .primary
    }

    private var balanceText: String {
        if vm.selectedDayEntries.isEmpty { return "—" }
        if vm.dayIsAllOff && vm.dayTotalHours == 0 { return "—" }
        return HoursFormatter.signedBalance(vm.dayBalance)
    }

    private var balanceColor: Color {
        if vm.selectedDayEntries.isEmpty { return .secondary }
        if vm.dayIsAllOff && vm.dayTotalHours == 0 { return .secondary }
        return .balanceColor(for: vm.dayBalance)
    }

    private var workEntryCount: Int {
        vm.selectedDayEntries.filter { !$0.isOffDay }.count
    }

    private var statusBadge: some View {
        Text(statusText)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(statusColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background {
                Capsule()
                    .fill(statusColor.opacity(0.12))
            }
    }

    private var statusText: String {
        if vm.dayIsAllOff { return "Day Off" }
        if vm.selectedDayEntries.isEmpty { return "No entries" }
        if vm.dayHasOffDay && vm.dayTotalHours == 0 { return "Day Off" }
        if vm.dayBalance > 0 { return "Overtime" }
        if vm.dayBalance == 0 { return "Target met" }
        let obligation = max(0, vm.settings.dailyTargetHours - vm.dayOffCreditHours)
        let remaining = obligation - vm.dayTotalHours
        let h = Int(remaining)
        let m = Int((remaining - Double(h)) * 60)
        return "\(h)h \(m)m left"
    }

    private var statusColor: Color {
        if vm.dayIsAllOff || (vm.dayHasOffDay && vm.dayTotalHours == 0) {
            return .balanceNegative
        }
        if vm.selectedDayEntries.isEmpty { return .secondary }
        if vm.dayBalance >= 0 { return .balancePositive }
        return .warningOrange
    }
}
