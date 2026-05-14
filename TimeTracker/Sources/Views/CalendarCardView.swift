import SwiftUI

/// Month calendar with navigation and color-coded days.
/// Work days = green, off-only days = red, today = orange, selected = purple.
struct CalendarCardView: View {
    @Bindable var vm: TimeTrackerViewModel

    private let weekdays = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    var body: some View {
        GroupBox {
            VStack(spacing: 8) {
                monthNavigation
                weekdayHeaders
                calendarGrid
            }
            .padding(.vertical, 4)
        } label: {
            Label("Calendar", systemImage: "calendar")
                .font(.headline)
        }
    }

    // MARK: - Month Navigation

    private var monthNavigation: some View {
        HStack {
            Button { vm.previousMonth() } label: {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.borderless)

            Spacer()

            Text(DateFormatter.monthYear.string(from: vm.selectedDate))
                .font(.subheadline.bold())

            Spacer()

            Button { vm.nextMonth() } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.borderless)
        }
    }

    // MARK: - Weekday Headers

    private var weekdayHeaders: some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        let days = calendarDays()
        return LazyVGrid(columns: columns, spacing: 2) {
            ForEach(days, id: \.id) { day in
                CalendarDayCell(
                    day: day,
                    isSelected: day.isSelected,
                    isToday: day.isToday,
                    hasWork: day.hasWork,
                    hasOffOnly: day.hasOffOnly
                ) {
                    if let date = day.date {
                        vm.selectedDate = date
                    }
                }
            }
        }
    }

    // MARK: - Day Generation

    private func calendarDays() -> [CalendarDay] {
        let cal = Calendar.current
        let year = cal.component(.year, from: vm.selectedDate)
        let month = cal.component(.month, from: vm.selectedDate)
        let firstOfMonth = cal.date(from: DateComponents(year: year, month: month, day: 1))!

        let firstWeekday = cal.component(.weekday, from: firstOfMonth)
        // Convert Sunday=1 to Monday-first offset
        let leadingEmpty = (firstWeekday + 5) % 7
        let daysInMonth = cal.range(of: .day, in: .month, for: firstOfMonth)!.count

        let today = cal.startOfDay(for: .now)
        let selectedDay = cal.startOfDay(for: vm.selectedDate)

        var days: [CalendarDay] = []

        // Leading empty cells
        for i in 0..<leadingEmpty {
            days.append(CalendarDay(id: "empty-\(i)", number: 0, date: nil))
        }

        // Actual days
        for day in 1...daysInMonth {
            let date = cal.date(from: DateComponents(year: year, month: month, day: day))!
            let dateStr = DateFormatter.isoDate.string(from: date)
            let dayStart = cal.startOfDay(for: date)

            days.append(CalendarDay(
                id: dateStr,
                number: day,
                date: date,
                isSelected: dayStart == selectedDay,
                isToday: dayStart == today,
                hasWork: vm.datesWithWork.contains(dateStr),
                hasOffOnly: vm.datesWithOffOnly.contains(dateStr)
            ))
        }

        return days
    }
}

// MARK: - Calendar Day Model

private struct CalendarDay {
    let id: String
    let number: Int
    let date: Date?
    var isSelected = false
    var isToday = false
    var hasWork = false
    var hasOffOnly = false
}

// MARK: - Calendar Day Cell

private struct CalendarDayCell: View {
    let day: CalendarDay
    let isSelected: Bool
    let isToday: Bool
    let hasWork: Bool
    let hasOffOnly: Bool
    let action: () -> Void

    var body: some View {
        Group {
            if day.number == 0 {
                Text("")
                    .frame(maxWidth: .infinity, minHeight: 28)
            } else {
                Button(action: action) {
                    Text("\(day.number)")
                        .font(.caption)
                        .fontWeight(isSelected || isToday ? .bold : .regular)
                        .frame(maxWidth: .infinity, minHeight: 28)
                        .foregroundStyle(foregroundColor)
                        .background(backgroundColor, in: RoundedRectangle(cornerRadius: 4))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var foregroundColor: Color {
        if isSelected { return .white }
        if isToday { return .black }
        if hasWork { return .calendarWork }
        if hasOffOnly { return .calendarOff }
        return .primary
    }

    private var backgroundColor: Color {
        if isSelected { return .calendarSelected }
        if isToday { return .calendarToday }
        return .clear
    }
}
