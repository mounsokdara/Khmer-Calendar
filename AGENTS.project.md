# Khmer Calendar

Private GitHub repo: `mounsokdara/Khmer-Carlendar`

After every app change:

1. Rebuild with `npm run build` (web app plus APK/Windows/Mac/Linux packs).
2. Commit and push **source** to `main`. Do not commit generated `apk-spa/` or `public/native/` binaries — those are created during publish.
3. If the user dislikes a change, revert that commit and push, then rebuild packages.
4. Pushing `main` runs GitHub Actions: it rebuilds the installers and publishes a GitHub Release. Do not skip that workflow.
