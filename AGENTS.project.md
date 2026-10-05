# Khmer Calendar

Every app change:

1. Preview (`npm run dev`) watches Dart and rebuilds the Flutter website by itself. You do not need to re-run `npm run build:web` for the live preview.
2. Pushing to `main` makes Cloudflare Pages (Git-connected) build the website from source with `bash tools/cf-build.sh` (Flutter web, no Vite, no GitHub Actions). Nothing generated is committed: there is no `website/` folder. Do not wait on a local web build for https://khmercalendar.pages.dev.
3. Pushing `main` also runs **Release**: it rebuilds the installers and publishes a GitHub Release.
4. Do not commit generated `website/`, `apk-spa/`, `dist/`, `flutter-web/`, `khmer_calendar/build/` or `public/native/` binaries.
5. If the user dislikes a change, revert that commit and push.
6. The public website must be the Flutter web app (same UI as this preview). Never publish the old HTML/Vite app.
