# Update notes

## 2026-05-27 — Statistics panel polish

- Statistics mode now takes over the full detail pane (timer, day summary, manual entry, and entries list are hidden).
- Statistics sections are separated with horizontal dividers between Day, Week, Month, and Overall.
- Use the chart toolbar button to switch between timer view and statistics view.

### Reinstall

```bash
./build-app.sh
cp -R "build/Time Tracker.app" /Applications/
open "/Applications/Time Tracker.app"
```

Your tracked time data is preserved across reinstalls.
