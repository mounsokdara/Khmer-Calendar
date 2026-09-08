# Khmer Calendar

Khmer lunar calendar for phone and desktop. Holy days, national holidays, weather, and reminders.

This repository is private.

## Run

```bash
npm install
npm run dev
```

## Packages

Install packs are **not stored in the repo**. `npm run build` (publish) creates them:

- `KhmerCalendar.apk`
- `KhmerCalendar.exe`
- `KhmerCalendar.dmg`
- `KhmerCalendar.AppImage`
- `KhmerCalendar-project.zip`

They land in `public/native/` for download from **More → Download**.

Web-only: `npm run build:web`. Packs only (after a web build): `npm run build:packages`.
