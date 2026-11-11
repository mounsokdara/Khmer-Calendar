#!/usr/bin/env bash
# Wraps the macOS updater script into a small app with the updater icon (down-arrow badge),
# so the standalone updater has its own icon in Finder instead of a generic script icon.
# Double-clicking the app opens Terminal and runs the same updater script.
#
# Usage: make-macos-updater-app.sh <out dir>      -> <out dir>/Khmer Calendar Updater.app
set -euo pipefail
OUT="${1:?output folder}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP="$OUT/Khmer Calendar Updater.app"
VERSION="$(sed -n 's/^versionName=//p' "$ROOT/version.txt" 2>/dev/null | tr -d '[:space:]')"; VERSION="${VERSION:-1.0}"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$ROOT/tools/icons/update.icns" "$APP/Contents/Resources/AppIcon.icns"
cp "$ROOT/tools/updater/update-macos.sh" "$APP/Contents/Resources/KhmerCalendar-Updater-macos.command"
chmod +x "$APP/Contents/Resources/KhmerCalendar-Updater-macos.command"

cat > "$APP/Contents/MacOS/KhmerCalendarUpdater" <<'SH'
#!/bin/bash
# Run the updater in Terminal (it asks questions and shows progress there).
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../Resources" && pwd)"
exec open -a Terminal "$DIR/KhmerCalendar-Updater-macos.command"
SH
chmod +x "$APP/Contents/MacOS/KhmerCalendarUpdater"

cat > "$APP/Contents/Info.plist" <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>Khmer Calendar Updater</string>
  <key>CFBundleDisplayName</key><string>Khmer Calendar Updater</string>
  <key>CFBundleIdentifier</key><string>com.mounsokdara.khmercalendar.updater</string>
  <key>CFBundleExecutable</key><string>KhmerCalendarUpdater</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>${VERSION}</string>
  <key>CFBundleVersion</key><string>${VERSION}</string>
  <key>LSMinimumSystemVersion</key><string>10.13</string>
  <key>LSUIElement</key><true/>
</dict>
</plist>
PL
echo "created $APP"
