import SwiftUI
import Combine

/// Central business logic for the time tracker. Owns all state: entries, timer, calendar, stats.
/// Views observe this via @Observable; SwiftUI only re-evaluates bodies that read changed properties.
@Observable
@MainActor
final class TimeTrackerViewModel {
    // MARK: - Dependencies

    var settings: AppSettings
    let storage: StorageService

    // MARK: - Entries

    private(set) var entries: [TimeEntry] = []

    // MARK: - Timer State

    private(set) var timerIsRunning = false
    private(set) var timerStartTime: Date?
    private(set) var timerElapsed: TimeInterval = 0
    private var timerTask: Task<Void, Never>?

    // MARK: - Calendar / Selection

    var selectedDate: Date = .now {
        didSet { updateDerivedState() }
    }

    // MARK: - Derived State (pre-computed, not in body)

    private(set) var selectedDayEntries: [TimeEntry] = []
    private(set) var dayTotalHours: Double = 0
    private(set) var dayBalance: Double = 0
    private(set) var dayIsAllOff: Bool = false

    private(set) var weekHours: Double = 0
    private(set) var weekBalance: Double = 0
    private(set) var weekDays: Int = 0

    private(set) var monthHours: Double = 0
    private(set) var monthBalance: Double = 0
    private(set) var monthDays: Int = 0
    private(set) var monthWeekdays: Int = 0

    private(set) var totalHours: Double = 0
    private(set) var totalBalance: Double = 0
    private(set) var totalDays: Int = 0
    private(set) var averageDailyHours: Double = 0

    /// Dates that have work entries (for calendar coloring)
    private(set) var datesWithWork: Set<String> = []
    /// Dates that only have off-day entries
    private(set) var datesWithOffOnly: Set<String> = []

    // MARK: - Init

    init(settings: AppSettings = AppSettings(), storage: StorageService? = nil) {
        self.settings = settings
        self.storage = storage ?? StorageService(settings: settings)
        loadData()
        restoreTimer()
    }

    // MARK: - Data Loading

    func loadData() {
        entries = storage.loadEntries()
        updateDerivedState()
    }

    func refreshData() {
        loadData()
    }

    // MARK: - Timer

    func toggleTimer() {
        timerIsRunning ? stopTimer() : startTimer()
    }

    func startTimer() {
        let now = Date.now
        timerIsRunning = true
        timerStartTime = now
        timerElapsed = 0
        TimerPersistenceService.save(isRunning: true, startTime: now)
        startTimerTick()
    }

    func stopTimer() {
        guard let start = timerStartTime else { return }
        timerIsRunning = false
        timerTask?.cancel()
        timerTask = nil

        let end = Date.now
        let entry = TimeEntry(
            date: start,
            startTime: DateFormatter.hourMinute.string(from: start),
            endTime: DateFormatter.hourMinute.string(from: end),
            isOffDay: false,
            note: "Timer session"
        )

        addEntry(entry)
        timerStartTime = nil
        timerElapsed = 0
        TimerPersistenceService.clear()
    }

    /// Formatted elapsed time "HH:MM:SS"
    var timerDisplay: String {
        let total = Int(timerElapsed)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    var timerStatusText: String {
        guard timerIsRunning, let start = timerStartTime else {
            return "Ready to start"
        }
        return "Started at \(DateFormatter.hourMinute.string(from: start))"
    }

    private func startTimerTick() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self, let start = self.timerStartTime else { break }
                self.timerElapsed = Date.now.timeIntervalSince(start)
            }
        }
    }

    private func restoreTimer() {
        if let savedStart = TimerPersistenceService.restore() {
            timerIsRunning = true
            timerStartTime = savedStart
            timerElapsed = Date.now.timeIntervalSince(savedStart)
            startTimerTick()
        }
    }

    // MARK: - Entry CRUD

    func addEntry(_ entry: TimeEntry) {
        entries.append(entry)
        if storage.saveEntries(entries) {
            updateDerivedState()
        } else {
            entries.removeLast()
        }
    }

    func addManualEntry(startTime: String, endTime: String, note: String, isOffDay: Bool) {
        let entry = TimeEntry(
            date: selectedDate,
            startTime: startTime,
            endTime: endTime,
            isOffDay: isOffDay,
            note: note
        )
        addEntry(entry)
    }

    func deleteEntry(_ entry: TimeEntry) {
        let backup = entries
        entries.removeAll { $0.id == entry.id }
        if storage.saveEntries(entries) {
            updateDerivedState()
        } else {
            entries = backup
        }
    }

    func updateEntry(_ entry: TimeEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        let backup = entries
        entries[idx] = entry
        if storage.saveEntries(entries) {
            updateDerivedState()
        } else {
            entries = backup
        }
    }

    // MARK: - Navigation

    func goToToday() {
        selectedDate = .now
    }

    func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }

    func nextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }

    // MARK: - Export

    func exportData() -> String {
        var output = "TIME TRACKER EXPORT\n"
        output += String(repeating: "=", count: 50) + "\n\n"
        output += "Generated: \(DateFormatter.fullDate.string(from: .now))\n"
        output += "Total Balance: \(HoursFormatter.signedBalance(totalBalance))\n"
        output += "Days Worked: \(totalDays)\n\n"

        let dates = Set(entries.map(\.dateString)).sorted().reversed()
        for dateStr in dates {
            let dayEntries = entries.filter { $0.dateString == dateStr }
            let hours = dailyHours(for: dateStr)
            let overtime = dailyBalance(for: dateStr)
            let allOff = dayEntries.allSatisfy(\.isOffDay)

            output += "\n\(dateStr)"
            if allOff {
                output += " [OFF DAY]"
            } else {
                output += " - \(String(format: "%.2f", hours))h (OT: \(HoursFormatter.signedBalance(overtime)))"
            }
            output += "\n" + String(repeating: "-", count: 30) + "\n"

            for e in dayEntries {
                if e.isOffDay {
                    output += "  OFF DAY"
                } else {
                    output += "  \(e.startTime) - \(e.endTime) (\(e.duration))"
                }
                if !e.note.isEmpty {
                    output += " - \(e.note)"
                }
                output += "\n"
            }
        }
        return output
    }

    // MARK: - Statistics Calculations

    private func dailyHours(for dateStr: String) -> Double {
        entries
            .filter { $0.dateString == dateStr && !$0.isOffDay }
            .reduce(0) { $0 + $1.durationHours }
    }

    private func dailyBalance(for dateStr: String) -> Double {
        let dayEntries = entries.filter { $0.dateString == dateStr }
        guard !dayEntries.isEmpty else { return 0 }
        if dayEntries.allSatisfy(\.isOffDay) { return 0 }
        return dailyHours(for: dateStr) - settings.dailyTargetHours
    }

    private func datesInRange(from start: Date, to end: Date) -> Set<String> {
        let startStr = DateFormatter.isoDate.string(from: start)
        let endStr = DateFormatter.isoDate.string(from: end)
        return Set(entries.map(\.dateString).filter { $0 >= startStr && $0 <= endStr })
    }

    private func workedDays(in dates: Set<String>) -> Int {
        dates.filter { dateStr in
            entries.filter { $0.dateString == dateStr }.contains { !$0.isOffDay }
        }.count
    }

    private func weekdaysInMonth(year: Int, month: Int) -> Int {
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: cal.date(from: DateComponents(year: year, month: month))!) else { return 0 }
        return range.filter { day in
            let date = cal.date(from: DateComponents(year: year, month: month, day: day))!
            return !cal.isDateInWeekend(date)
        }.count
    }

    // MARK: - Derived State Update

    /// Recompute all derived state from entries + selectedDate.
    /// Called after any mutation. Keeps body computation trivial.
    private func updateDerivedState() {
        let cal = Calendar.current
        let dateStr = DateFormatter.isoDate.string(from: selectedDate)

        // Selected day
        selectedDayEntries = entries.filter { $0.dateString == dateStr }
        dayTotalHours = dailyHours(for: dateStr)
        dayBalance = dailyBalance(for: dateStr)
        dayIsAllOff = !selectedDayEntries.isEmpty && selectedDayEntries.allSatisfy(\.isOffDay)

        // Week (ISO: Monday-Sunday)
        let weekday = cal.component(.weekday, from: selectedDate)
        let daysFromMonday = (weekday + 5) % 7
        let monday = cal.date(byAdding: .day, value: -daysFromMonday, to: selectedDate)!
        let sunday = cal.date(byAdding: .day, value: 6, to: monday)!
        let weekDates = datesInRange(from: monday, to: sunday)
        weekHours = weekDates.reduce(0) { $0 + dailyHours(for: $1) }
        weekBalance = weekDates.reduce(0) { $0 + dailyBalance(for: $1) }
        weekDays = workedDays(in: weekDates)

        // Month
        let year = cal.component(.year, from: selectedDate)
        let month = cal.component(.month, from: selectedDate)
        let firstOfMonth = cal.date(from: DateComponents(year: year, month: month, day: 1))!
        let lastDay = cal.range(of: .day, in: .month, for: firstOfMonth)!.upperBound - 1
        let lastOfMonth = cal.date(from: DateComponents(year: year, month: month, day: lastDay))!
        let monthDates = datesInRange(from: firstOfMonth, to: lastOfMonth)
        monthHours = monthDates.reduce(0) { $0 + dailyHours(for: $1) }
        monthBalance = monthDates.reduce(0) { $0 + dailyBalance(for: $1) }
        self.monthDays = workedDays(in: monthDates)
        monthWeekdays = weekdaysInMonth(year: year, month: month)

        // Overall
        let allDates = Set(entries.map(\.dateString))
        totalHours = allDates.reduce(0) { $0 + dailyHours(for: $1) }
        totalBalance = allDates.reduce(0) { $0 + dailyBalance(for: $1) }
        totalDays = workedDays(in: allDates)
        averageDailyHours = totalDays > 0 ? totalHours / Double(totalDays) : 0

        // Calendar color sets
        var work = Set<String>()
        var offOnly = Set<String>()
        for dateStr in allDates {
            let dayEntries = entries.filter { $0.dateString == dateStr }
            if dayEntries.contains(where: { !$0.isOffDay }) {
                work.insert(dateStr)
            } else {
                offOnly.insert(dateStr)
            }
        }
        datesWithWork = work
        datesWithOffOnly = offOnly
    }
}
