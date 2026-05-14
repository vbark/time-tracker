# Time Tracker

A native macOS time-tracking app built with SwiftUI. Tracks work hours against a configurable daily target (default 8h), calculates overtime balance, and persists data to CSV.

## Features

- **Timer** — Start/stop with live elapsed display. Persists across app restarts via UserDefaults.
- **Manual Entry** — Add entries with start/end time, note, and off-day toggle.
- **Entry Management** — Edit (double-click) and delete (right-click) entries.
- **Calendar** — Month view with color-coded days (work=green, off=red, today=orange, selected=purple).
- **Statistics** — Selected day/week/month/overall: hours worked, expected, balance, days.
- **Menu Bar** — Always-visible timer status, today's progress, quick start/stop.
- **iCloud Drive** — CSV stored in iCloud Drive folder for automatic sync.
- **Dark/Light Mode** — Follows system appearance natively.
- **Keyboard Shortcuts** — Cmd+T (timer), Cmd+R (refresh), Cmd+N (add entry), Escape (today), Cmd+, (settings).

## CSV Format

Compatible with the original Python time-tracker app:

```
date,start_time,end_time,duration,is_off_day,is_overtime_taken,note
2026-05-14,09:00,17:00,08:00,false,false,Regular day
```

## Storage

- **Primary**: `~/Library/Mobile Documents/com~apple~CloudDocs/TimeTracker/time_log.csv` (iCloud Drive)
- **Backup**: `~/Library/Application Support/TimeTracker/time_log_backup.csv` (local)
- Configurable via Settings (Cmd+,)

## Build & Run

Requires macOS 14+ and Swift 6.0+.

```bash
cd TimeTracker
swift build
swift run
```

Or open `TimeTracker.xcodeproj` in Xcode (if installed):

```bash
xcodegen generate   # regenerate project if needed
open TimeTracker.xcodeproj
```

## Requirements

- macOS 14.0+
- Swift 6.0+
- Xcode 16+ (optional, for xcodeproj) or Swift CLI tools
