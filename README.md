# Khmer Calendar

Khmer lunar calendar for phone and desktop. Holy days, national holidays, weather, and reminders.

This repository is private.

## Run

```bash
npm install
npm run dev
```

## Packages

Download builds live in `public/native/`:

- `KhmerCalendar.apk`
- `KhmerCalendar.exe`
- `KhmerCalendar.dmg`
- `KhmerCalendar.AppImage`
- `KhmerCalendar-project.zip`

`npm run build` builds the web app and the install packs (APK, Windows, Mac, Linux).

```bash
npm run build
```

Packs are written to `public/native/`. Web-only: `npm run build:web`. Packs only: `npm run build:packages`.
