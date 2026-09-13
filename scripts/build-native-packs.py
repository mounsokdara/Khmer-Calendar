#!/usr/bin/env python3
"""Build KhmerCalendar.exe / .dmg / .AppImage / project.zip into public/native/."""
from __future__ import annotations

import os
import shutil
import struct
import subprocess
import tempfile
import urllib.request
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "public" / "native"
SPA = ROOT / "apk-spa"
NEU = Path(os.environ.get("KHMER_NEU_DIR", "/tmp/neu"))
SFX = ROOT / "scripts" / "sfx.c"
MARKER = b"KHCALPKG"
NEU_VERSION = os.environ.get("KHMER_NEU_VERSION", "6.2.0")
ZIG_VERSION = "0.13.0"
NEU_BINARIES = (
    "neutralino-linux_x64",
    "neutralino-win_x64.exe",
    "neutralino-mac_universal",
)


CONFIG = """{
  "applicationId": "kh.chhankitek.calendar",
  "version": "1.0.0",
  "defaultMode": "window",
  "port": 0,
  "documentRoot": "/www/",
  "url": "/",
  "enableServer": true,
  "enableNativeAPI": true,
  "nativeAllowList": ["app.*", "os.*", "filesystem.*", "storage.*", "window.*"],
  "modes": {
    "window": {
      "title": "ប្រតិទិនខ្មែរ",
      "width": 420,
      "height": 860,
      "minWidth": 360,
      "minHeight": 640,
      "fullScreen": false,
      "alwaysOnTop": false,
      "icon": "/www/icon-192.png",
      "enableInspector": false,
      "resizable": true,
      "exitProcessOnClose": true
    }
  }
}
"""

INFO_PLIST = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>Khmer Calendar</string>
  <key>CFBundleDisplayName</key><string>Khmer Calendar</string>
  <key>CFBundleIdentifier</key><string>kh.chhankitek.calendar</string>
  <key>CFBundleVersion</key><string>1.0.0</string>
  <key>CFBundleShortVersionString</key><string>1.0.0</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleExecutable</key><string>KhmerCalendar</string>
  <key>LSMinimumSystemVersion</key><string>11.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
"""


def inject_html(src: Path, platform: str) -> bytes:
    html = src.read_bytes().replace(b"\x00", b"")
    flag_true = (
        f"window.__KHMER_PACKAGED=true;window.KhmerNative={{platform:{platform!r}}}"
    ).encode()
    html = html.replace(
        b"window.__KHMER_PACKAGED=window.__KHMER_PACKAGED||false",
        flag_true,
        1,
    )
    if b"__KHMER_PACKAGED=true" not in html:
        needle = b"<head>"
        script = (f"<head><script>{flag_true.decode()};</script>").encode()
        if needle in html:
            html = html.replace(needle, script, 1)
    return html


def copy_www(dest: Path, platform: str) -> None:
    dest.mkdir(parents=True, exist_ok=True)
    skip = {".DS_Store"}
    for root, dirs, files in os.walk(SPA):
        dirs[:] = [d for d in dirs if d not in skip]
        rel = Path(root).relative_to(SPA)
        (dest / rel).mkdir(parents=True, exist_ok=True)
        for name in files:
            if name in skip:
                continue
            src = Path(root) / name
            out = dest / rel / name
            if name == "index.html":
                out.write_bytes(inject_html(src, platform))
            else:
                shutil.copy2(src, out)
    weather_src = ROOT / "public" / "weather"
    if weather_src.is_dir():
        (dest / "weather").mkdir(exist_ok=True)
        for jpg in weather_src.glob("*.jpg"):
            target = dest / "weather" / jpg.name
            if not target.exists():
                shutil.copy2(jpg, target)


def zip_dir(src: Path, dest: Path, arc_prefix: str = "") -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(dest, "w", zipfile.ZIP_DEFLATED) as z:
        for p in src.rglob("*"):
            if p.is_file():
                rel = p.relative_to(src)
                arc = f"{arc_prefix}{rel.as_posix()}" if arc_prefix else rel.as_posix()
                z.write(p, arc)


def append_payload(stub: Path, payload: Path, dest: Path) -> None:
    data = stub.read_bytes() + payload.read_bytes()
    data += struct.pack("<Q", payload.stat().st_size) + MARKER
    dest.write_bytes(data)
    dest.chmod(0o755)


def find_zig() -> Path:
    env = os.environ.get("KHMER_ZIG")
    if env:
        p = Path(env)
        if p.is_file():
            return p
    which = shutil.which("zig")
    if which:
        return Path(which)
    local = Path("/tmp/zig/zig")
    if local.is_file():
        return local
    raise SystemExit("zig compiler not found (set KHMER_ZIG or install zig 0.13.0)")


def ensure_zig() -> Path:
    try:
        return find_zig()
    except SystemExit:
        pass
    if os.name != "posix" or os.uname().machine not in {"x86_64", "amd64"}:
        raise SystemExit("zig is missing and this platform cannot auto-download it")
    url = f"https://ziglang.org/download/{ZIG_VERSION}/zig-linux-x86_64-{ZIG_VERSION}.tar.xz"
    dest_dir = Path("/tmp/zig")
    dest_dir.mkdir(parents=True, exist_ok=True)
    archive = dest_dir / f"zig-linux-x86_64-{ZIG_VERSION}.tar.xz"
    print(f"downloading zig {ZIG_VERSION}")
    urllib.request.urlretrieve(url, archive)
    subprocess.check_call(["tar", "-xJf", str(archive), "-C", str(dest_dir)])
    extracted = dest_dir / f"zig-linux-x86_64-{ZIG_VERSION}" / "zig"
    if not extracted.is_file():
        raise SystemExit("zig download did not contain a zig binary")
    link = dest_dir / "zig"
    if link.exists() or link.is_symlink():
        link.unlink()
    link.symlink_to(extracted)
    os.chmod(extracted, 0o755)
    return extracted


def ensure_neu() -> None:
    NEU.mkdir(parents=True, exist_ok=True)
    missing = [name for name in NEU_BINARIES if not (NEU / name).is_file()]
    if not missing:
        return
    url = f"https://github.com/neutralinojs/neutralinojs/releases/download/v{NEU_VERSION}/neutralinojs-v{NEU_VERSION}.zip"
    archive = NEU / f"neutralinojs-v{NEU_VERSION}.zip"
    print(f"downloading Neutralino v{NEU_VERSION}")
    urllib.request.urlretrieve(url, archive)
    with zipfile.ZipFile(archive) as z:
        names = z.namelist()
        for needed in NEU_BINARIES:
            match = next((n for n in names if n.rstrip("/").endswith(needed) and not n.endswith("/")), None)
            if match is None:
                raise SystemExit(f"Neutralino zip is missing {needed}")
            target = NEU / needed
            target.write_bytes(z.read(match))
            os.chmod(target, 0o755)
    archive.unlink(missing_ok=True)


def compile_sfx_windows(dest: Path, zig: Path) -> None:
    subprocess.check_call(
        [
            str(zig),
            "cc",
            "-target",
            "x86_64-windows-gnu",
            "-O2",
            "-s",
            str(SFX),
            "-o",
            str(dest),
            "-lkernel32",
            "-lshell32",
        ]
    )



def compile_sfx_linux(dest: Path) -> None:
    subprocess.check_call(["gcc", "-O2", "-s", str(SFX), "-o", str(dest)])


def make_iso(src_dir: Path, dest: Path, volume: str = "KHMERCAL") -> None:
    """Minimal ISO 9660 (Joliet-less, long names via 9660 level 3-ish)."""
    files: list[tuple[str, Path, int]] = []
    for p in sorted(src_dir.rglob("*")):
        rel = p.relative_to(src_dir).as_posix()
        if p.is_file():
            files.append((rel, p, p.stat().st_size))

    sector = 2048
    sys_area = bytes(16 * sector)
    # We'll write a very small ISO: primary volume + root + file extents.
    # For reliability, use a zip-in-iso named KhmerCalendar.app.zip plus a README
    # AND also the raw .app tree with short names if needed.
    # Prefer: pack the whole tree as one file INSTALL.ZIP plus README.TXT
    # Mac users can still open a dmg that is ISO with a .app folder if names fit.
    records: list[bytes] = []

    def pad_name(name: str) -> str:
        n = "".join(ch if ch.isalnum() or ch in "._-" else "_" for ch in name)
        return n[:31] or "FILE"

    # Build a simple ISO with directories flattened using path separators as _
    # Better: write README and a zip of the .app
    app_zip = src_dir / "_app.zip"
    if not app_zip.exists():
        zip_dir(src_dir, app_zip)

    contents = [
        ("README.TXT", b"Khmer Calendar for macOS.\nOpen KhmerCalendar.app\n"),
    ]
    # include every file with sanitized names under a flat-ish tree — too lossy.
    # Include the zip and try to include Info.plist / binary with original names via Joliet skip.
    contents.append(("KhmerCalendar.app.zip", app_zip.read_bytes()))

    # Also copy the .app as a directory using ISO directories (short names).
    extra_files = []
    for p in src_dir.rglob("*"):
        if p.is_file() and p.name != "_app.zip":
            extra_files.append((p.relative_to(src_dir).as_posix(), p.read_bytes()))

    # Use a real ISO writer with path tables for extra_files + zip + readme
    entries = [("README.TXT", contents[0][1]), ("APP.ZIP", contents[1][1])]
    for rel, data in extra_files:
        entries.append((pad_name(rel.replace("/", "_")), data))

    # Primary volume descriptor + terminator + data
    root_extent_sector = 20
    data_blobs: list[bytes] = []
    file_meta = []  # (name, sector, size)
    cursor = root_extent_sector + 2
    for name, blob in entries:
        file_meta.append((name, cursor, len(blob)))
        padded = blob + bytes((sector - (len(blob) % sector)) % sector)
        data_blobs.append(padded)
        cursor += len(padded) // sector

    def dr(name: bytes, loc: int, size: int, flags: int = 0) -> bytes:
        ident = name
        n = 33 + len(ident)
        if n % 2:
            n += 1
        rec = bytearray(n)
        rec[0] = n
        rec[2:6] = struct.pack("<I", loc)
        rec[6:10] = struct.pack(">I", loc)
        rec[10:14] = struct.pack("<I", size)
        rec[14:18] = struct.pack(">I", size)
        rec[18:25] = bytes([0x7E, 1, 1, 1, 0, 0, 0])  # 2026-01-01-ish
        rec[25] = flags
        rec[32] = len(ident)
        rec[33 : 33 + len(ident)] = ident
        return bytes(rec)

    root_size = 2048
    root = bytearray(root_size)
    off = 0
    for ident, loc, size, flags in [
        (b"\x00", root_extent_sector, root_size, 2),
        (b"\x01", root_extent_sector, root_size, 2),
    ]:
        rec = dr(ident, loc, size, flags)
        root[off : off + len(rec)] = rec
        off += len(rec)
    for name, loc, size in file_meta:
        ident = name.encode("ascii")
        rec = dr(ident, loc, size, 0)
        if off + len(rec) < root_size:
            root[off : off + len(rec)] = rec
            off += len(rec)

    def pvd() -> bytes:
        b = bytearray(sector)
        b[0] = 1
        b[1:6] = b"CD001"
        b[6] = 1
        b[8:40] = b"APPLE".ljust(32)
        vol = volume.encode("ascii")[:32].ljust(32)
        b[40:72] = vol
        total_sectors = cursor
        b[80:84] = struct.pack("<I", total_sectors)
        b[84:88] = struct.pack(">I", total_sectors)
        b[120:124] = struct.pack("<H", 1)
        b[124:126] = struct.pack(">H", 1)
        b[126:128] = struct.pack("<H", 1)
        b[128:130] = struct.pack(">H", 1)
        b[130:132] = struct.pack("<H", 1)
        b[132:134] = struct.pack(">H", 1)
        b[156 : 156 + 34] = dr(b"\x00", root_extent_sector, root_size, 2)[:34]
        b[318:446] = b"KHMER CALENDAR".ljust(128)
        b[881] = 1
        return bytes(b)

    term = bytearray(sector)
    term[0] = 255
    term[1:6] = b"CD001"
    term[6] = 1

    parts = [sys_area, pvd(), bytes(sector), bytes(sector), bytes(term), bytes((root_extent_sector - 20) * sector), bytes(root), bytes(sector)]
    # 16 sys + 1 pvd + 2 pad + 1 term = 20 sectors. Then root at 20.
    out = bytearray()
    out.extend(sys_area)
    out.extend(pvd())
    out.extend(bytes(sector))  # 17
    out.extend(bytes(sector))  # 18
    out.extend(term)  # 19
    out.extend(bytes(root))  # 20
    out.extend(bytes(sector))  # 21
    for blob in data_blobs:
        out.extend(blob)
    dest.write_bytes(bytes(out))
    try:
        app_zip.unlink()
    except OSError:
        pass


def build_www_payload(tmp: Path, platform: str, binary: Path, bin_name: str) -> Path:
    root = tmp / platform
    www = root / "www"
    copy_www(www, platform)
    (root / "neutralino.config.json").write_text(CONFIG, encoding="utf-8")
    bindir = root / "bin"
    bindir.mkdir(parents=True, exist_ok=True)
    shutil.copy2(binary, bindir / bin_name)
    os.chmod(bindir / bin_name, 0o755)
    zpath = tmp / f"{platform}.zip"
    zip_dir(root, zpath)
    return zpath


def build_project_zip(dest: Path) -> None:
    skip_dir = {"node_modules", ".git", "artifacts", "screenshots", "apk-spa", "attachments", ".vercel", ".tanstack", ".grok"}
    skip_file_suffix = {".exe", ".dmg", ".AppImage", ".zip", ".jar", ".apk", ".keystore"}
    skip_names = {
        "KhmerCalendar.exe",
        "KhmerCalendar.dmg",
        "KhmerCalendar.AppImage",
        "KhmerCalendar-project.zip",
        "apktool.jar",
        "uber-apk-signer.jar",
        "khmer-release.keystore",
    }
    dest.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(dest, "w", zipfile.ZIP_DEFLATED) as z:
        for dirpath, dirnames, filenames in os.walk(ROOT):
            dirnames[:] = [d for d in dirnames if d not in skip_dir]
            for name in filenames:
                p = Path(dirpath) / name
                if not p.is_file():
                    continue
                rel = p.relative_to(ROOT)
                if rel.name in skip_names or p.suffix in skip_file_suffix:
                    continue
                if "native" in rel.parts and rel.name != ".gitkeep":
                    continue
                z.write(p, f"KhmerCalendar/{rel.as_posix()}")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    ensure_neu()
    zig = ensure_zig()
    with tempfile.TemporaryDirectory() as td:
        tmp = Path(td)
        win_zip = build_www_payload(tmp, "windows", NEU / "neutralino-win_x64.exe", "KhmerCalendar.exe")
        lin_zip = build_www_payload(tmp, "linux", NEU / "neutralino-linux_x64", "KhmerCalendar")
        mac_root = tmp / "macroot"
        app = mac_root / "KhmerCalendar.app"
        contents = app / "Contents"
        macos = contents / "MacOS"
        res = contents / "Resources"
        macos.mkdir(parents=True)
        copy_www(res / "www", "macos")
        (res / "neutralino.config.json").write_text(CONFIG, encoding="utf-8")
        shutil.copy2(NEU / "neutralino-mac_universal", macos / "KhmerCalendar")
        os.chmod(macos / "KhmerCalendar", 0o755)
        (contents / "Info.plist").write_text(INFO_PLIST, encoding="utf-8")
        launcher = """#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
RES="$DIR/../Resources"
exec "$DIR/KhmerCalendar.bin" --path="$RES" --res-mode=directory
"""
        shutil.move(str(macos / "KhmerCalendar"), str(macos / "KhmerCalendar.bin"))
        (macos / "KhmerCalendar").write_text(launcher, encoding="utf-8")
        os.chmod(macos / "KhmerCalendar", 0o755)
        os.chmod(macos / "KhmerCalendar.bin", 0o755)

        stub_win = tmp / "stub.exe"
        compile_sfx_windows(stub_win, zig)
        append_payload(stub_win, win_zip, OUT / "KhmerCalendar.exe")

        stub_lin = tmp / "stub-linux"
        compile_sfx_linux(stub_lin)
        append_payload(stub_lin, lin_zip, OUT / "KhmerCalendar.AppImage")

        make_iso(mac_root, OUT / "KhmerCalendar.dmg", "KHMERCAL")

    build_project_zip(OUT / "KhmerCalendar-project.zip")
    for name in ["KhmerCalendar.exe", "KhmerCalendar.dmg", "KhmerCalendar.AppImage", "KhmerCalendar-project.zip"]:
        p = OUT / name
        print(f"{name}: {p.stat().st_size} bytes magic={p.read_bytes()[:4]!r}")


if __name__ == "__main__":
    main()
