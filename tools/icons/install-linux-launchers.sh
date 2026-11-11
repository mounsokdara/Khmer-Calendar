#!/bin/sh
# Adds "Khmer Calendar Updater" and "Khmer Calendar Background Service" to the application menu
# with their own icons (down-arrow badge / gear badge). Linux programs cannot carry an icon inside
# the file, so the icons come from these launcher entries instead.
#
# Run it once from the extracted Khmer Calendar folder (the one that has update-linux-* and
# khmer-calendar-bg):   sh install-linux-launchers.sh      Remove them again:   sh install-linux-launchers.sh --remove
set -eu
DIR="$(cd "$(dirname "$0")" && pwd)"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
APPS="$DATA/applications"
ICONS="$DATA/icons/hicolor/512x512/apps"
UPD_ID=com.mounsokdara.khmercalendar.updater
BG_ID=com.mounsokdara.khmercalendar.background

if [ "${1:-}" = "--remove" ]; then
  rm -f "$APPS/$UPD_ID.desktop" "$APPS/$BG_ID.desktop" "$ICONS/$UPD_ID.png" "$ICONS/$BG_ID.png"
  command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$APPS" 2>/dev/null || true
  echo "launchers removed"; exit 0
fi

UPD="$(ls "$DIR"/update-linux-* 2>/dev/null | head -n 1 || true)"
BG="$DIR/khmer-calendar-bg"
[ -n "$UPD" ] && [ -x "$UPD" ] || { echo "update-linux-* not found next to this script" >&2; exit 1; }
[ -x "$BG" ] || { echo "khmer-calendar-bg not found next to this script" >&2; exit 1; }
[ -f "$DIR/icons/khmer-calendar-update.png" ] && [ -f "$DIR/icons/khmer-calendar-bg.png" ] || { echo "icons/ folder is missing" >&2; exit 1; }

mkdir -p "$APPS" "$ICONS"
cp "$DIR/icons/khmer-calendar-update.png" "$ICONS/$UPD_ID.png"
cp "$DIR/icons/khmer-calendar-bg.png" "$ICONS/$BG_ID.png"

# Exec paths with spaces/quotes must be quoted in a .desktop file.
q() { printf '"%s"' "$(printf '%s' "$1" | sed 's/\\/\\\\\\\\/g; s/"/\\\\"/g; s/`/\\\\`/g; s/\$/\\\\$/g')"; }

cat > "$APPS/$UPD_ID.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Khmer Calendar Updater
Comment=Check for and install Khmer Calendar updates
Exec=$(q "$UPD") --app-dir $(q "$DIR")
Icon=$UPD_ID
Terminal=false
Categories=Utility;
EOF
cat > "$APPS/$BG_ID.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Khmer Calendar Background Service
Comment=Start Khmer Calendar in the background (reminders, notifications)
Exec=$(q "$BG") --app-dir $(q "$DIR")
Icon=$BG_ID
Terminal=false
Categories=Utility;
EOF
chmod +x "$APPS/$UPD_ID.desktop" "$APPS/$BG_ID.desktop"
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$APPS" 2>/dev/null || true
command -v gtk-update-icon-cache >/dev/null 2>&1 && gtk-update-icon-cache -q -t "$DATA/icons/hicolor" 2>/dev/null || true
echo "launchers added to $APPS"
