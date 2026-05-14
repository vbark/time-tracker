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

ICON_SRC="Resources/Assets.xcassets/AppIcon.appiconset/time-tracker.png"
if [ -f "$ICON_SRC" ]; then
    echo "Creating .icns from icon..."
    ICONSET_DIR=$(mktemp -d)/AppIcon.iconset
    mkdir -p "$ICONSET_DIR"
    sips -z 16 16     "$ICON_SRC" --out "$ICONSET_DIR/icon_16x16.png"      >/dev/null 2>&1
    sips -z 32 32     "$ICON_SRC" --out "$ICONSET_DIR/icon_16x16@2x.png"   >/dev/null 2>&1
    sips -z 32 32     "$ICON_SRC" --out "$ICONSET_DIR/icon_32x32.png"      >/dev/null 2>&1
    sips -z 64 64     "$ICON_SRC" --out "$ICONSET_DIR/icon_32x32@2x.png"   >/dev/null 2>&1
    sips -z 128 128   "$ICON_SRC" --out "$ICONSET_DIR/icon_128x128.png"    >/dev/null 2>&1
    sips -z 256 256   "$ICON_SRC" --out "$ICONSET_DIR/icon_128x128@2x.png" >/dev/null 2>&1
    sips -z 256 256   "$ICON_SRC" --out "$ICONSET_DIR/icon_256x256.png"    >/dev/null 2>&1
    sips -z 512 512   "$ICON_SRC" --out "$ICONSET_DIR/icon_256x256@2x.png" >/dev/null 2>&1
    sips -z 512 512   "$ICON_SRC" --out "$ICONSET_DIR/icon_512x512.png"    >/dev/null 2>&1
    sips -z 1024 1024 "$ICON_SRC" --out "$ICONSET_DIR/icon_512x512@2x.png" >/dev/null 2>&1
    iconutil -c icns "$ICONSET_DIR" -o "$RESOURCES/AppIcon.icns"
    rm -rf "$(dirname "$ICONSET_DIR")"
    echo "Icon created."
else
    echo "Warning: No icon source found at $ICON_SRC"
fi

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
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
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
