#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

APP_DIR="build/TimeTracker.app"
CONTENTS="$APP_DIR/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

echo "Building release binary..."
swift build -c release

echo "Creating .app bundle..."
rm -rf "$APP_DIR"
mkdir -p "$MACOS" "$RESOURCES"

cp .build/release/TimeTracker "$MACOS/TimeTracker"

cat > "$CONTENTS/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Time Tracker</string>
    <key>CFBundleDisplayName</key>
    <string>Time Tracker</string>
    <key>CFBundleIdentifier</key>
    <string>com.victor.timetracker</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleExecutable</key>
    <string>TimeTracker</string>
    <key>LSMinimumSystemVersion</key>
    <string>15.0</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

echo "Done! App bundle at: $SCRIPT_DIR/$APP_DIR"
echo ""
echo "To install to Applications:"
echo "  cp -R $SCRIPT_DIR/$APP_DIR /Applications/"
echo ""
echo "To launch now:"
echo "  open $SCRIPT_DIR/$APP_DIR"
