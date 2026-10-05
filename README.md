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

## Windows: installer or portable
- **Setup wizard:** `KhmerCalendar-windows-setup.exe` installs for the current user (no admin needed), adds a Start menu shortcut and an uninstaller.
- **Portable zip:** `KhmerCalendar-windows.zip`, unzip anywhere and run `khmer_calendar.exe`. Nothing is installed.

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

