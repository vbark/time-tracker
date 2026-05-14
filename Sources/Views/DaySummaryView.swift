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
                .fill(.ultraThinMaterial)
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
        vm.dayIsAllOff ? "Off Day" : HoursFormatter.duration(vm.dayTotalHours)
    }

    private var totalColor: Color {
        vm.dayIsAllOff ? .balanceNegative : .primary
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
        if vm.dayBalance > 0 { return "Overtime" }
        if vm.dayBalance == 0 { return "Target met" }
        let remaining = vm.settings.dailyTargetHours - vm.dayTotalHours
        let h = Int(remaining)
        let m = Int((remaining - Double(h)) * 60)
        return "\(h)h \(m)m left"
    }

    private var statusColor: Color {
        if vm.dayIsAllOff { return .balanceNegative }
        if vm.selectedDayEntries.isEmpty { return .secondary }
        if vm.dayBalance >= 0 { return .balancePositive }
        return .warningOrange
    }
}
