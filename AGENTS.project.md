# Khmer Calendar

Private GitHub repo: `mounsokdara/Khmer-Calendar`

After every app change:

1. Rebuild with `npm run build` (web app plus APK/Windows/Mac/Linux packs).
2. Commit and push **source** to `main`, including `website/` (Flutter web for Cloudflare Pages at https://khmercalendar.pages.dev). Do not commit generated `apk-spa/`, `dist/`, `flutter-web/`, or `public/native/` binaries. Those last three are created during publish.
3. If the user dislikes a change, revert that commit and push, then rebuild packages.
4. Pushing `main` runs GitHub Actions: it rebuilds the installers and publishes a GitHub Release. Do not skip that workflow.
5. The public website must be the Flutter web app (same UI as this preview). Never publish the old HTML/Vite app.
