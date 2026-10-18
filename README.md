# Khmer Calendar

Native Flutter Khmer lunar calendar for phone and desktop. Holy days, national holidays, weather, reminders and a bunch of cool features.

**Visit this Website for demo:** [khmercalendar.pages.dev](https://khmercalendar.pages.dev)
## Run app

```bash
cd khmer_calendar
flutter pub get
flutter run
```

To run the web version:

```bash
cd khmer_calendar
flutter run -d chrome
```

## Download:
[In my GitHub Releases](https://github.com/mounsokdara/Khmer-Calendar/releases/latest)

## Privacy
[Privacy Policy](PRIVACY.md): no accounts, ads or analytics; your data stays on your device.

## Packages (one file per architecture)
Every release has standalone files, each with its architecture in the name. Pick the one for your device:
- **Android:** `KhmerCalendar-arm64.apk` (almost every phone), `-arm32.apk` (old 32-bit phones), `-x64.apk` (emulators, Intel Chromebooks), `-arm32_64.apk` (arm + arm64 in one file) or `-universal.apk` (arm, arm64 and x64 in one file).
- **Windows:** `KhmerCalendar-windows-x64.zip`, `KhmerCalendar-windows-arm64.zip`, plus the x64 setup wizard below.
- **macOS:** `KhmerCalendar-macos-arm64.dmg` (Apple Silicon), `-x86_64.dmg` (Intel) or `-universal.dmg` (both).
- **Linux:** `KhmerCalendar-linux-x64.tar.gz` or `KhmerCalendar-linux-arm64.tar.gz`.

Flutter cannot build 32-bit x86 or ARMv5/v6 (`armeabi`), so there are no such packages.

## Windows: installer or portable
- **Setup wizard:** `KhmerCalendar-windows-setup.exe` installs for the current user (no admin needed), adds a Start menu shortcut and an uninstaller.
- **Portable:** `KhmerCalendar-windows-x64.zip` (Intel/AMD) or `KhmerCalendar-windows-arm64.zip` (ARM PCs), unzip anywhere and run `khmer_calendar.exe`. Nothing is installed.

## Windows: "Unknown publisher" warning
The Windows zip is signed with the maintainer's own certificate, which Windows does not recognise, so SmartScreen may say "Windows protected your PC". Click **More info**, then **Run anyway**.

## Deploy (Cloudflare Pages, built from source)

Full guide: [docs/DEPLOY.md](docs/DEPLOY.md).

The website is generated on Cloudflare from `khmer_calendar/` on every commit. No GitHub Actions deploy and no generated files in the repo.

Dashboard: *Workers & Pages > khmercalendar > Settings > Builds*:

| Setting | Value |
|---|---|
| Production branch | `main` |
| Framework preset | None |
| Build command | `bash tools/cf-build.sh` |
| Build output directory | `khmer_calendar/build/web` (also set in `wrangler.toml`) |
| Root directory | *(empty)* |

Environment variables (Production and Preview):

| Variable | Value | Purpose |
|---|---|---|
| `FLUTTER_VERSION` | optional, e.g. `3.47.4` | Pin Flutter (default `3.47.4`, same as the Release workflow). |
<!-- If you have access/permission to changees my repo, make sure you have to update https://github.com/mounsokdara/Khmer-Calendar.Dev to avoid commit too many changes everyday. so we can have clean public releasing repo. when the app look finish, you can now publish to the main public repo -->

