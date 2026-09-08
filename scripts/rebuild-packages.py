#!/usr/bin/env python3
"""Refresh apk-spa from the latest Vite build, then rebuild native packs and the APK."""
from __future__ import annotations

import os
import shutil
import subprocess
import tempfile
import urllib.request
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SPA = ROOT / "apk-spa"
STATIC = ROOT / ".vercel" / "output" / "static"
PUBLIC = ROOT / "public"
NATIVE = PUBLIC / "native"
APK = NATIVE / "KhmerCalendar.apk"
KEYSTORE = ROOT / "scripts" / "khmer-release.keystore"
SIGNER = ROOT / "scripts" / "uber-apk-signer.jar"
SIGNER_URL = "https://github.com/patrickfav/uber-apk-signer/releases/download/v1.3.0/uber-apk-signer-1.3.0.jar"

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


def newest(folder: Path, pattern: str) -> Path:
    files = [p for p in folder.glob(pattern) if p.is_file()]
    if not files:
        raise SystemExit(f"missing {pattern} in {folder}")
    files.sort(key=lambda p: p.stat().st_mtime, reverse=True)
    # Prefer the largest index bundle (the real app entry).
    if pattern.startswith("index-") and pattern.endswith(".js"):
        files.sort(key=lambda p: p.stat().st_size, reverse=True)
    return files[0]


def build_shell(assets: Path) -> bytes:
    css = newest(assets, "styles-*.css").name
    entry = newest(assets, "index-*.js").name
    jsx = newest(assets, "jsx-runtime-*.js").name
    routes = newest(assets, "routes-*.js").name
    settings = newest(assets, "settings-ui-*.js").name
    html = f"""<!DOCTYPE html><html lang="km"><head>
<meta charSet="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"/>
<title>ប្រតិទិនខ្មែរ</title>
<meta name="theme-color" content="#9A3B38"/>
<meta name="color-scheme" content="light dark"/>
<meta name="mobile-web-app-capable" content="yes"/>
<meta name="apple-mobile-web-app-capable" content="yes"/>
<meta name="apple-mobile-web-app-title" content="ប្រតិទិនខ្មែរ"/>
<meta name="description" content="ប្រតិទិនចន្ទគតិខ្មែរ ថ្ងៃសីល ថ្ងៃឈប់សម្រាក និងព្រឹត្តិការណ៍។"/>
<link rel="stylesheet" href="/apk-app.css"/>
<link rel="stylesheet" href="/assets/{css}" data-precedence="default"/>
<link rel="modulepreload" href="/assets/{entry}"/>
<link rel="modulepreload" href="/assets/{jsx}"/>
<link rel="modulepreload" href="/assets/{routes}"/>
<link rel="modulepreload" href="/assets/{settings}"/>
<link rel="icon" type="image/svg+xml" href="/favicon.svg"/>
<link rel="icon" type="image/png" sizes="192x192" href="/icon-192.png"/>
<link rel="icon" type="image/png" sizes="512x512" href="/icon-512.png"/>
<link rel="manifest" href="/manifest.webmanifest"/>
<link rel="apple-touch-icon" href="/apple-touch-icon.png"/>
<link rel="preload" href="/material-symbols.woff2" as="font" type="font/woff2" crossorigin="anonymous"/>
<script>window.__KHMER_PACKAGED=true;</script>
<script>(function(){{try{{var d=false;if(window.KhmerNative){{try{{var n=window.KhmerNative.isNightMode();d=n===true||n===1||n==='1'||n==='true';}}catch(e){{}}}}else if(window.matchMedia&&window.matchMedia('(prefers-color-scheme: dark)').matches)d=true;var r=document.documentElement;r.classList.toggle('dark',d);r.style.colorScheme=d?'dark':'light';}}catch(e){{}}}})();</script>
</head><body class="antialiased">
<div class="md-shell"><div class="tab-stage"></div></div>
<script class="$tsr" id="$tsr-stream-barrier">(self.$R=self.$R||{{}})["tsr"]=[];self.$_TSR={{h(){{this.hydrated=!0,this.c()}},e(){{this.streamEnded=!0,this.c()}},c(){{this.hydrated&&this.streamEnded&&(delete self.$_TSR,delete self.$R.tsr)}},p(e){{this.initialized?e():this.buffer.push(e)}},buffer:[]}};$_TSR.router=($R=>$R[0]={{manifest:$R[1]={{routes:$R[2]={{__root__:$R[3]={{preloads:$R[4]=["/assets/{entry}","/assets/{jsx}"],scripts:$R[5]=[$R[6]={{attrs:$R[7]={{type:"module",async:!0,src:"/assets/{entry}"}}}}]}}}},matches:$R[8]=[$R[9]={{i:"__root__",u:{int(__import__("time").time()*1000)},s:"success",ssr:!0}}]}})($R["tsr"]);$_TSR.e();document.currentScript.remove()</script>
<script type="module" async="" src="/assets/{entry}"></script>
</body></html>
"""
    return html.encode("utf-8")


def refresh_spa() -> None:
    if not STATIC.is_dir():
        raise SystemExit("No production web build yet (.vercel/output/static is missing).")
    src_assets = STATIC / "assets"
    shell = build_shell(src_assets)

    # Reset route HTML, keep weather/zodiac/fonts/icons.
    for stale in ["today"]:
        p = SPA / stale
        if p.exists():
            shutil.rmtree(p)

    spa_assets = SPA / "assets"
    if spa_assets.exists():
        shutil.rmtree(spa_assets)
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
        if dest.exists():
            shutil.rmtree(dest)
        shutil.copytree(src, dest)

    (SPA / "_shell.html").write_bytes(shell)
    for route in ROUTES:
        dest = SPA / route if route else SPA
        dest.mkdir(parents=True, exist_ok=True)
        (dest / "index.html").write_bytes(shell)
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
    if not APK.exists():
        raise SystemExit("missing existing APK template")
    ensure_keystore()
    ensure_signer()
    with tempfile.TemporaryDirectory() as td:
        tmp = Path(td)
        unsigned = tmp / "unsigned.apk"
        with zipfile.ZipFile(APK) as src, zipfile.ZipFile(unsigned, "w") as dest:
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


def sync_native_into_web_build() -> None:
    if not STATIC.is_dir() or not NATIVE.is_dir():
        return
    dest = STATIC / "native"
    dest.mkdir(parents=True, exist_ok=True)
    for p in NATIVE.iterdir():
        if p.is_file():
            shutil.copy2(p, dest / p.name)


def main() -> None:
    if os.environ.get("VERCEL") == "1":
        print("skip package rebuild on Vercel")
        return
    refresh_spa()
    rebuild_native()
    rebuild_apk()
    sync_native_into_web_build()


if __name__ == "__main__":
    main()
