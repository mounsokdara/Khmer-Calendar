#!/usr/bin/env python3
"""Refresh apk-spa from the latest Vite build, then rebuild native packs and the APK."""
from __future__ import annotations

import os
import re
import shutil
import subprocess
import tempfile
import time
import urllib.request
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SPA = ROOT / "apk-spa"
STATIC = ROOT / ".vercel" / "output" / "static"
PUBLIC = ROOT / "public"
NATIVE = PUBLIC / "native"
APK = NATIVE / "KhmerCalendar.apk"
TEMPLATE = ROOT / "scripts" / "apk-template.apk"
KEYSTORE = ROOT / "scripts" / "khmer-release.keystore"
SIGNER = ROOT / "scripts" / "uber-apk-signer.jar"
SIGNER_URL = "https://github.com/patrickfav/uber-apk-signer/releases/download/v1.3.0/uber-apk-signer-1.3.0.jar"

PACK_FILES = (
    "KhmerCalendar.apk",
    "KhmerCalendar.exe",
    "KhmerCalendar.dmg",
    "KhmerCalendar.AppImage",
    "KhmerCalendar-project.zip",
)

ROUTES = [
    "",
    "day",
    "months",
    "events",
    "weather",
    "more",
    "download",
    "get-started",
    "settings",
    "settings/clear",
    "settings/theme",
    "settings/privacyandpermission",
    "tools",
    "tools/datecalculator",
]


PACKAGED_BOOT = (
    b"<script>window.__KHMER_PACKAGED=true;"
    b"(function(){try{if(location.protocol!=='file:'&&/\\/index\\.html$/i.test(location.pathname))"
    b"history.replaceState(null,'',location.pathname.replace(/\\/index\\.html$/i,'/')+location.search+location.hash);}"
    b"catch(e){}})();</script>"
)
FLAG_FALSE = b"window.__KHMER_PACKAGED=window.__KHMER_PACKAGED||false"
FLAG_TRUE = b"window.__KHMER_PACKAGED=true"


def inject_packaged(html: bytes) -> bytes:
    html = html.replace(b"\x00", b"")
    html = re.sub(rb'<script src="https://grok\.com/[^"]*"\s*defer></script>', b"", html)
    html = html.replace(b'href="/__grok/manifest.webmanifest"', b'href="/manifest.webmanifest"')
    html = re.sub(rb'<link rel="apple-touch-icon" href="/__grok/icon-180.png">', b"", html)
    if FLAG_FALSE in html:
        html = html.replace(FLAG_FALSE, FLAG_TRUE, 1)
    elif b"__KHMER_PACKAGED=true" not in html:
        html = html.replace(b"<head>", b"<head>" + PACKAGED_BOOT, 1)
    return html


def fetch_preview(path: str) -> bytes:
    url = f"http://127.0.0.1:8081/{path}" if path else "http://127.0.0.1:8081/"
    last = "no response"
    for _ in range(16):
        try:
            with urllib.request.urlopen(url, timeout=30) as res:
                data = res.read()
            if b"<html" in data.lower() or b"<!DOCTYPE" in data.upper():
                return data
            last = f"non-html response for /{path} ({len(data)} bytes)"
        except Exception as exc:
            last = str(exc)
        time.sleep(0.5)
    raise SystemExit(f"failed to capture /{path}: {last}")


def capture_route_html() -> None:
    subprocess.check_call(["npm", "run", "preview:restart"], cwd=ROOT)
    try:
        for route in ROUTES:
            html = inject_packaged(fetch_preview(route))
            if b"boot-splash" not in html or b"/assets/index-" not in html:
                raise SystemExit(f"packaged HTML for /{route} is missing the app boot")
            if b"__KHMER_PACKAGED=true" not in html:
                raise SystemExit(f"packaged HTML for /{route} is missing the packaged flag")
            dest = SPA / route if route else SPA
            dest.mkdir(parents=True, exist_ok=True)
            (dest / "index.html").write_bytes(html)
        (SPA / "_shell.html").write_bytes((SPA / "index.html").read_bytes())
    finally:
        subprocess.check_call(["npm", "run", "preview:stop"], cwd=ROOT)


def prune_assets() -> None:
    assets = SPA / "assets"
    if not assets.is_dir():
        return
    needed: set[str] = set()
    queue: list[Path] = []

    def add_name(name: str) -> None:
        name = name.split("?", 1)[0].split("#", 1)[0]
        if not name or name in needed:
            return
        p = assets / name
        if not p.is_file():
            return
        needed.add(name)
        queue.append(p)

    for html in SPA.rglob("*.html"):
        for match in re.finditer(rb"/assets/([A-Za-z0-9._@-]+)", html.read_bytes()):
            add_name(match.group(1).decode())

    import_re = re.compile(
        rb"""(?:from|import)\s*["']\./([^"']+)["']|import\(["']\./([^"']+)["']\)|(?:/)?assets/([A-Za-z0-9._@-]+)"""
    )
    while queue:
        path = queue.pop()
        if path.suffix not in {".js", ".mjs", ".css"}:
            continue
        data = path.read_bytes()
        for match in import_re.finditer(data):
            rel = match.group(1) or match.group(2) or match.group(3)
            add_name(Path(rel.decode()).name)

    removed = 0
    for path in assets.iterdir():
        if path.is_file() and path.name not in needed:
            path.unlink()
            removed += 1
    print(f"apk-spa assets: kept {len(needed)}, pruned {removed}")


def refresh_spa() -> None:
    if not STATIC.is_dir():
        raise SystemExit("No production web build yet (.vercel/output/static is missing).")
    src_assets = STATIC / "assets"

    if SPA.exists():
        shutil.rmtree(SPA)
    SPA.mkdir(parents=True)

    spa_assets = SPA / "assets"
    shutil.copytree(src_assets, spa_assets)

    copy_names = [
        "apk-app.css",
        "favicon.svg",
        "apple-touch-icon.png",
        "icon-192.png",
        "icon-192-maskable.png",
        "icon-512.png",
        "icon-512-maskable.png",
        "manifest.webmanifest",
        "material-symbols.woff2",
        "og.jpg",
    ]
    for name in copy_names:
        src = PUBLIC / name
        if src.exists():
            shutil.copy2(src, SPA / name)

    for folder in ["fonts", "weather", "zodiac"]:
        src = PUBLIC / folder
        dest = SPA / folder
        if not src.is_dir():
            continue
        shutil.copytree(src, dest)

    capture_route_html()
    prune_assets()
    print("apk-spa refreshed")


def rebuild_native() -> None:
    subprocess.check_call(["python3", str(ROOT / "scripts" / "build-native-packs.py")], cwd=ROOT)


def ensure_keystore() -> None:
    if KEYSTORE.exists():
        return
    subprocess.check_call(
        [
            "keytool",
            "-genkeypair",
            "-v",
            "-keystore",
            str(KEYSTORE),
            "-alias",
            "khmer",
            "-keyalg",
            "RSA",
            "-keysize",
            "2048",
            "-validity",
            "10000",
            "-storepass",
            "khmercal",
            "-keypass",
            "khmercal",
            "-dname",
            "CN=Khmer Calendar, O=Khmer Calendar, C=KH",
        ]
    )


def ensure_signer() -> None:
    if SIGNER.exists() and SIGNER.stat().st_size > 100_000:
        return
    tmp = SIGNER.with_suffix(".jar.tmp")
    print("downloading APK signer")
    urllib.request.urlretrieve(SIGNER_URL, tmp)
    tmp.replace(SIGNER)


def copy_zip_entry(dest: zipfile.ZipFile, name: str, data: bytes, compress_type: int) -> None:
    info = zipfile.ZipInfo(filename=name)
    info.compress_type = compress_type
    info.create_system = 0
    info.create_version = 20
    info.extract_version = 20
    info.external_attr = 0
    dest.writestr(info, data)


def has_v2_sig(apk: Path) -> bool:
    data = apk.read_bytes()
    eocd = data.rfind(b"PK\x05\x06")
    if eocd < 0:
        return False
    cd_off = int.from_bytes(data[eocd + 16 : eocd + 20], "little")
    return data.rfind(b"APK Sig Block 42", 0, cd_off) >= 0


def rebuild_apk() -> None:
    if not TEMPLATE.exists():
        raise SystemExit("missing scripts/apk-template.apk")
    ensure_keystore()
    ensure_signer()
    NATIVE.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as td:
        tmp = Path(td)
        unsigned = tmp / "unsigned.apk"
        with zipfile.ZipFile(TEMPLATE) as src, zipfile.ZipFile(unsigned, "w") as dest:
            for info in src.infolist():
                name = info.filename
                if name.startswith("assets/www/") or name.startswith("META-INF/"):
                    continue
                copy_zip_entry(dest, name, src.read(info), info.compress_type)
            for p in SPA.rglob("*"):
                if not p.is_file():
                    continue
                rel = p.relative_to(SPA).as_posix()
                data = p.read_bytes()
                stored = rel.endswith((".png", ".jpg", ".woff2", ".webp"))
                copy_zip_entry(dest, f"assets/www/{rel}", data, zipfile.ZIP_STORED if stored else zipfile.ZIP_DEFLATED)
        out_dir = tmp / "signed"
        out_dir.mkdir()
        subprocess.check_call(
            [
                "java",
                "-jar",
                str(SIGNER),
                "--apks",
                str(unsigned),
                "--allowResign",
                "--ks",
                str(KEYSTORE),
                "--ksAlias",
                "khmer",
                "--ksPass",
                "khmercal",
                "--ksKeyPass",
                "khmercal",
                "--out",
                str(out_dir),
                "--verbose",
            ]
        )
        signed = next(out_dir.glob("*.apk"), None)
        if signed is None:
            raise SystemExit("APK signer produced no apk")
        if not has_v2_sig(signed):
            raise SystemExit("APK is missing v2/v3 signature (Android 11+ will refuse install)")
        shutil.copy2(signed, APK)
        print(f"apk rebuilt: {APK.stat().st_size} bytes (v2 signed)")


def clean_stale_native() -> None:
    NATIVE.mkdir(parents=True, exist_ok=True)
    wanted = set(PACK_FILES) | {".gitkeep"}
    for path in NATIVE.iterdir():
        if path.is_file() and path.name not in wanted:
            path.unlink()
            print(f"removed leftover pack {path.name}")


def verify_packs() -> None:
    missing = [name for name in PACK_FILES if not (NATIVE / name).is_file() or (NATIVE / name).stat().st_size < 1000]
    if missing:
        raise SystemExit(f"missing published packs: {', '.join(missing)}")
    if not has_v2_sig(APK):
        raise SystemExit("published APK is missing v2/v3 signature")
    html = zipfile.ZipFile(APK).read("assets/www/index.html")
    if b"boot-splash" not in html or b"__KHMER_PACKAGED=true" not in html:
        raise SystemExit("published APK is missing the app boot")


def sync_native_into_web_build() -> None:
    if not STATIC.is_dir() or not NATIVE.is_dir():
        return
    dest = STATIC / "native"
    if dest.exists():
        shutil.rmtree(dest)
    dest.mkdir(parents=True, exist_ok=True)
    for name in PACK_FILES:
        src = NATIVE / name
        if src.is_file():
            shutil.copy2(src, dest / name)


def main() -> None:
    if os.environ.get("VERCEL") == "1":
        print("skip package rebuild on Vercel")
        return
    refresh_spa()
    rebuild_native()
    rebuild_apk()
    clean_stale_native()
    verify_packs()
    sync_native_into_web_build()


if __name__ == "__main__":
    main()
