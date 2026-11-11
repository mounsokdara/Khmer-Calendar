#!/usr/bin/env bash
# Regenerates tools/icons/{update,bg}.{png,ico,icns} from khmer_calendar/assets/icons/icon-512.png.
# Works on any machine/CI runner: uses Pillow if present, else installs it in a throwaway venv.
set -euo pipefail
cd "$(dirname "$0")"
PY=$(command -v python3 || command -v python)
if ! "$PY" -c 'import PIL' 2>/dev/null; then
  V="${TMPDIR:-/tmp}/khmer-icons-venv"
  "$PY" -m venv "$V"
  PY="$V/bin/python"; [ -x "$PY" ] || PY="$V/Scripts/python"
  "$PY" -m pip install --quiet pillow
fi
"$PY" make_icons.py "$@"
