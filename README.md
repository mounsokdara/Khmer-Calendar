# Khmer Calendar

Native Flutter Khmer lunar calendar for phone and desktop. Holy days, national holidays, weather, reminders and a bunch of cool features.

**Visit this Website for demo:** [khmercalendar.pages.dev](https://khmercalendar.pages.dev)

**Dev Preview**
[https://khmer-calendar-dev.pnsdg.workers.dev/](https://khmer-calendar-dev.pnsdg.workers.dev/)
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

## Dev builds: update inside the app
In this dev repo every push to `main` runs **Release** (`release.yml`), which builds Android APKs and Windows / Linux / macOS packages (`android.yml`, `windows.yml`, `linux.yml`, `macos.yml`) and publishes them to the GitHub Release for the current version. Each desktop package includes its updater. **About > Check for updates** downloads the right package for your device and installs it without opening GitHub: Android opens the system installer; on Windows (`update-windows.exe`), Linux and macOS a small updater waits for the app to quit, swaps the files and restarts it. Source: `khmer_calendar/lib/screens/more/dev_update*.dart`, `tools/updater/`.

**Update without opening the app:** download the updater for your system from the release and run it: `KhmerCalendar-Updater-windows-x64.exe` (Windows), `KhmerCalendar-Updater-linux-x64` / `-arm64` (Linux, make it executable first), or `KhmerCalendar-Updater-macos.zip` (macOS, unzip, then right-click the `.command` file > Open). It finds the installed app (or asks for the folder, or use `--app-dir <folder>`), checks the installed version against the latest one (nothing is downloaded when you are already up to date; add `--force-update 1` to reinstall anyway), downloads the latest package, closes the app if it is running, updates it and starts it again. If another program is using the app files it shows which one and offers Retry, Force close, and Force as administrator when a normal force close was not enough. Windows may show "Unknown publisher" and macOS may say the developer cannot be verified because the files are not signed yet.

## Icons for the updater and background service
The update service and the background service have their own icons: the app icon with a down-arrow badge (updater) or a gear badge (background service). They are drawn automatically from `khmer_calendar/assets/icons/icon-512.png` by `tools/icons/make_icons.py` (badge position and colours are picked from the app icon; run `bash tools/icons/generate.sh` after changing the icon, and CI runs it before packaging); the generated files are in `tools/icons/`.

- **Windows:** the icon is embedded into `update-windows.exe` and `khmer-calendar-bg.exe` while the package is built (`tools/icons/set-icon-windows.ps1`, which keeps the plain exe if the check fails).
- **macOS:** the standalone updater zip also has `Khmer Calendar Updater.app` with the icon (it runs the same updater in Terminal).
- **Linux:** a program file cannot hold an icon, so the package has `install-linux-launchers.sh`: run `sh install-linux-launchers.sh` in the extracted folder to add both to the application menu with their icons (`--remove` undoes it).

## Privacy
[Privacy Policy](PRIVACY.md): no accounts, ads or analytics; your data stays on your device.

## Code signing policy
I have applied to the SignPath Foundation for free code signing of the Windows app; no release is signed by it yet, so Windows may show "Unknown publisher" until then. Roles, scope and how signing will work: [Code signing policy](docs/CODE-SIGNING-POLICY.md).

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
<!-- read me if youre an ai agens look at AGENTS.project.md-->
