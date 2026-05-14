import SwiftUI

struct CalendarCardView: View {
    @Bindable var vm: TimeTrackerViewModel

    private let weekdays = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    var body: some View {
        VStack(spacing: 10) {
            monthNavigation
            weekdayHeaders
            calendarGrid
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
        }
    }

    private var monthNavigation: some View {
        HStack {
            Button { vm.previousMonth() } label: {
                Image(systemName: "chevron.left")
                    .font(.caption.weight(.semibold))
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.borderless)

            Spacer()

            Text(DateFormatter.monthYear.string(from: vm.selectedDate))
                .font(.subheadline.bold())

            Spacer()

            Button { vm.nextMonth() } label: {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.borderless)
        }
    }

    private var weekdayHeaders: some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var calendarGrid: some View {
        let days = calendarDays()
        return LazyVGrid(columns: columns, spacing: 4) {
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

    private func calendarDays() -> [CalendarDay] {
        let cal = Calendar.current
        let year = cal.component(.year, from: vm.selectedDate)
        let month = cal.component(.month, from: vm.selectedDate)
        let firstOfMonth = cal.date(from: DateComponents(year: year, month: month, day: 1))!

        let firstWeekday = cal.component(.weekday, from: firstOfMonth)
        let leadingEmpty = (firstWeekday + 5) % 7
        let daysInMonth = cal.range(of: .day, in: .month, for: firstOfMonth)!.count

        let today = cal.startOfDay(for: .now)
        let selectedDay = cal.startOfDay(for: vm.selectedDate)

        var days: [CalendarDay] = []

        for i in 0..<leadingEmpty {
            days.append(CalendarDay(id: "empty-\(i)", number: 0, date: nil))
        }

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

private struct CalendarDay {
    let id: String
    let number: Int
    let date: Date?
    var isSelected = false
    var isToday = false
    var hasWork = false
    var hasOffOnly = false
}

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
                Color.clear
                    .frame(height: 30)
            } else {
                Button(action: action) {
                    ZStack {
                        if isSelected {
                            Circle()
                                .fill(Color.accentColor)
                        } else if isToday {
                            Circle()
                                .strokeBorder(Color.accentColor, lineWidth: 1.5)
                        }

                        Text("\(day.number)")
                            .font(.system(size: 12, weight: fontWeight))
                            .foregroundStyle(foregroundColor)
                    }
                    .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
                .overlay(alignment: .bottom) {
                    if hasWork && !isSelected {
                        Circle()
                            .fill(Color.calendarWork)
                            .frame(width: 4, height: 4)
                            .offset(y: -2)
                    } else if hasOffOnly && !isSelected {
                        Circle()
                            .fill(Color.calendarOff)
                            .frame(width: 4, height: 4)
                            .offset(y: -2)
                    }
                }
            }
        }
    }

    private var fontWeight: Font.Weight {
        if isSelected || isToday { return .semibold }
        return .regular
    }

    private var foregroundColor: Color {
        if isSelected { return .white }
        if isToday { return .accentColor }
        return .primary
    }
}
