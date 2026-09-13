#!/usr/bin/env python3
"""Native Flutter installers are built on GitHub Actions (see .github/workflows/release.yml).

This hook stays so `npm run build` still succeeds locally and on hosted web deploys.
It does not wrap the calendar in a WebView anymore.
"""
from __future__ import annotations

import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
NATIVE = ROOT / "public" / "native"


def hosted_ci() -> bool:
    if os.environ.get("KHMER_BUILD_PACKS") == "1":
        return False
    if os.environ.get("KHMER_SKIP_PACKS") == "1":
        return True
    if os.environ.get("GITHUB_ACTIONS") in {"true", "1"}:
        return False
    if os.environ.get("VERCEL") == "1":
        return True
    if os.environ.get("CF_PAGES") or os.environ.get("WORKERS_CI") or os.environ.get("CLOUDFLARE_ACCOUNT_ID"):
        return True
    if os.environ.get("NETLIFY") or os.environ.get("RENDER"):
        return True
    if os.environ.get("CI") in {"true", "1"}:
        return True
    home = os.environ.get("HOME", "")
    if "buildhome" in home or "vercel" in home:
        return True
    return False


def main() -> int:
    NATIVE.mkdir(parents=True, exist_ok=True)
    if hosted_ci():
        print("skip installer packaging on hosted web deploy (Flutter packs are GitHub Releases)")
        return 0
    print("Flutter native installers (APK / Windows / macOS / Linux) are built on GitHub Actions.")
    print("See https://github.com/mounsokdara/Khmer-Carlendar/releases/latest")
    return 0


if __name__ == "__main__":
    sys.exit(main())
