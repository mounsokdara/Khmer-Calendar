# Khmer Calendar

Private GitHub repo: `mounsokdara/Khmer-Calendar`

After every app change:

1. Preview (`npm run dev`) watches Dart and rebuilds the Flutter website by itself. You do not need to re-run `npm run build:web` for the live preview.
2. Pushing Dart / web / asset changes to `main` runs the **Website** workflow: it rebuilds `website/` from Flutter, deploys Cloudflare Pages, and commits `website/` so Git-connected Pages stays in sync. Do not wait on a local web build for https://khmercalendar.pages.dev.
3. Pushing `main` also runs **Release**: it rebuilds the installers and publishes a GitHub Release. Website-only commits do not retrigger that.
4. Do not commit generated `apk-spa/`, `dist/`, `flutter-web/`, or `public/native/` binaries. Those last three are created during publish.
5. If the user dislikes a change, revert that commit and push.
6. The public website must be the Flutter web app (same UI as this preview). Never publish the old HTML/Vite app.
