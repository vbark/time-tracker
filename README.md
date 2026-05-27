# Time Tracker

Native macOS app for tracking work hours, calculating overtime balance, and syncing time data via iCloud Drive.

**SwiftUI** · **macOS 15+** · **Swift 6** · **Menu bar app** · **iCloud sync**

## Features

| Area | What it does |
|------|----------------|
| **Timer** | Start/stop with live elapsed time. Survives app restarts—the original start time is stored in UserDefaults. |
| **Manual entry** | Add entries with start/end times, optional note, and off-day toggle on the selected calendar date. |
| **Entry list** | Table with time range, duration, note, and type. Double-click to edit; right-click for Edit / Delete. |
| **Calendar** | Month view with navigation. Color-coded days: work (green), off (red), today (orange), selected (purple). |
| **Statistics** | Day, week, month, and overall stats—hours worked, expected, balance, and days. Toggle via the chart toolbar button. |
| **Menu bar** | Always-visible icon with popover: timer status, today’s progress, quick start/stop, and overall balance. |
| **iCloud Drive** | CSV in iCloud Drive with automatic sync. Local backup as fallback. Path configurable in Settings. |
| **Appearance** | Follows system light/dark mode with accent colors that adapt automatically. |

## Keyboard shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘T` | Toggle timer (start/stop) |
| `⌘N` | Add manual entry from the form |
| `⌘R` | Refresh data from file |
| `⌘,` | Open Settings (daily target, storage path) |
| `Escape` | Jump to today’s date |
| Double-click entry | Edit entry |
| Right-click entry | Context menu (Edit / Delete) |

Toolbar: use the **chart** button to switch between the timer/detail view and the full statistics panel.

## CSV format

Backward-compatible with the original Python time-tracker. Drop in an existing `time_log.csv` and the app reads it as-is.

| Column | Format | Description |
|--------|--------|-------------|
| `date` | `YYYY-MM-DD` | Entry date |
| `start_time` | `HH:MM` | Work start (24h) |
| `end_time` | `HH:MM` | Work end (24h) |
| `duration` | `HH:MM` | Calculated duration (`00:00` on off days) |
| `is_off_day` | `true` / `false` | Off days do not affect balance |
| `is_overtime_taken` | `true` / `false` | Reserved for future use |
| `note` | Free text | Optional note |

Example:

```csv
date,start_time,end_time,duration,is_off_day,is_overtime_taken,note
2026-05-14,08:15,12:30,04:15,false,false,Morning session
2026-05-14,13:00,17:00,04:00,false,false,Afternoon session
2026-05-15,09:00,17:00,00:00,true,false,Public holiday
```

## Storage

| Location | Path | Purpose |
|----------|------|---------|
| **Primary (iCloud)** | `~/Library/Mobile Documents/com~apple~CloudDocs/TimeTracker/time_log.csv` | Syncs via iCloud Drive |
| **Backup (local)** | `~/Library/Application Support/TimeTracker/time_log_backup.csv` | Offline fallback and crash recovery |
| **Timer state** | UserDefaults | Running timer survives restarts |
| **Settings** | UserDefaults | Daily target hours, storage path, preferences |

**Dual-storage:** Every save writes to primary and backup. On load, the newer file wins. If the primary is unavailable, the backup is used and a warning is shown.

**Custom path:** Open Settings (`⌘,`) to point the primary file anywhere (another iCloud folder, Dropbox, or a local path). The backup always stays in Application Support.

## Timer persistence

1. **On start** — Original start time is saved to UserDefaults immediately.
2. **On restart** — App resumes counting from the saved start time; no elapsed time is lost.
3. **On stop** — A time entry is created with the original start and current end time; UserDefaults is cleared.

## Statistics

Pre-computed whenever entries change. Balance logic matches the Python app:

- **Daily balance** = hours worked − daily target (default 8h)
- **Off days** are excluded entirely (0h, not −8h)
- **Week** uses ISO weeks (Monday → Sunday)
- **Expected hours** shown as tracked days × target / weekdays × target

| Section | Metrics |
|---------|---------|
| Hero balance | Overall overtime balance (large, color-coded) |
| Selected day | Worked, balance |
| Selected week | Worked, expected, balance, days |
| Selected month | Worked, expected, balance, days |
| Overall | Worked, expected, avg daily, balance, days |

Statistics mode replaces the detail pane (timer, day summary, manual entry, and entry list are hidden until you toggle back).

## Architecture

```
TimeTrackerApp (@main)
├── Window → MainView (NavigationSplitView)
│   ├── Sidebar: overall balance + CalendarCardView
│   └── Detail (toolbar: Today, Refresh, Export, Statistics toggle)
│       ├── TimerView, DaySummaryView, ManualEntryView, EntriesListView
│       └── StatisticsPanelView (full detail when toggled)
├── MenuBarExtra (.window) → MenuBarView
└── Settings → StorageSettingsView
```

**Patterns**

- **`@Observable` ViewModel** — Single source of truth on `@MainActor`. Derived state (day totals, balances, calendar colors) is pre-computed on mutation.
- **CSVService** — Stateless read/write; supports legacy files without a `note` column; handles quoted commas.
- **StorageService** — Dual-file writes, newest-on-load, status and warnings.
- **TimerPersistenceService** — UserDefaults timer state, recovered on launch.

## Build and run

### App bundle (recommended)

```bash
./build-app.sh
open "build/Time Tracker.app"
```

### Install to Applications

```bash
cp -R "build/Time Tracker.app" /Applications/
open "/Applications/Time Tracker.app"
```

### Development

```bash
swift build
swift run
```

### Requirements

- macOS 15.0+
- Swift 6.0+ (Xcode 16+ or Command Line Tools)

Tracked time data is preserved across reinstalls.

## Project structure

```
├── Package.swift
├── build-app.sh
├── README.md
├── Sources/
│   ├── App/
│   │   ├── TimeTrackerApp.swift
│   │   └── AppDelegate.swift
│   ├── Models/
│   │   ├── TimeEntry.swift
│   │   └── AppSettings.swift
│   ├── ViewModels/
│   │   └── TimeTrackerViewModel.swift
│   ├── Views/
│   │   ├── MainView.swift
│   │   ├── TimerView.swift
│   │   ├── ManualEntryView.swift
│   │   ├── EntriesListView.swift
│   │   ├── DaySummaryView.swift
│   │   ├── StatisticsView.swift
│   │   ├── CalendarCardView.swift
│   │   ├── MenuBarView.swift
│   │   ├── StorageSettingsView.swift
│   │   ├── TrackerToolbarButtons.swift
│   │   └── Components/
│   │       └── StatRow.swift
│   ├── Services/
│   │   ├── CSVService.swift
│   │   ├── StorageService.swift
│   │   ├── TimerPersistenceService.swift
│   │   └── LaunchAtLoginService.swift
│   └── Utilities/
│       ├── DateFormatting.swift
│       ├── Color+Theme.swift
│       └── AppWindowController.swift
└── Resources/
    ├── Assets.xcassets/
    └── Info.plist
```
