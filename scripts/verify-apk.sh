#!/usr/bin/env bash
# Verify (never modify) the release APK that Gradle already signed.
#
# Gradle signs the APK with the release keystore (android/app/build.gradle.kts).
# Re-signing it afterwards with apksigner rewrote the signature blocks (forced a
# legacy v1 signature on a minSdk 24 app), which is what Play Protect started
# flagging. This script only reads the APK, so the file you ship is byte-for-byte
# what Gradle produced.
#
# Usage: KS_FILE=key.jks KS_PASS=... KEY_ALIAS=... verify-apk.sh <app-release.apk>
# KS_* are optional: when set, the signing certificate must match the keystore.
set -euo pipefail
APK="${1:?apk path}"
[ -f "$APK" ] || { echo "::error::APK not found: $APK"; exit 1; }

SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
BT="$(ls -d "$SDK"/build-tools/*/ 2>/dev/null | sort -V | tail -1)"
APKSIGNER="${BT}apksigner"
[ -x "$APKSIGNER" ] || { echo "::error::apksigner not found under $SDK/build-tools"; exit 1; }
echo "Using $APKSIGNER"

# 1. Official verifier. --min-sdk-version 24 matches the app, so the legacy v1
#    (JAR) scheme is skipped exactly like on a real device.
if ! REPORT="$("$APKSIGNER" verify --verbose --print-certs --min-sdk-version 24 "$APK" 2>&1)"; then
  echo "$REPORT"
  echo "::error::apksigner verify FAILED"
  exit 1
fi
echo "$REPORT" | grep -E "^Verifies|Verified using|Number of signers|certificate SHA-256" || true

# Here-strings, not `echo | grep -q`: with `pipefail`, grep -q closing the pipe
# early can make the pipeline return 141 and fail a perfectly valid APK.
grep -qF "Verified using v2 scheme (APK Signature Scheme v2): true" <<<"$REPORT" \
  || { echo "::error::APK Signature Scheme v2 missing"; exit 1; }
grep -qF "Verified using v3 scheme (APK Signature Scheme v3): true" <<<"$REPORT" \
  || echo "::warning::APK Signature Scheme v3 not present (v2 is enough on Android 7+)"

# 2. Certificate must be the release key, never the debug key.
GOT="$(grep -m1 'certificate SHA-256 digest' <<<"$REPORT" | awk '{print $NF}' | tr 'A-F' 'a-f')"
[ -n "$GOT" ] || { echo "::error::could not read the signing certificate"; exit 1; }
if [ -n "${KS_FILE:-}" ] && [ -n "${KS_PASS:-}" ] && [ -n "${KEY_ALIAS:-}" ]; then
  WANT="$(keytool -list -v -keystore "$KS_FILE" -storepass "$KS_PASS" -alias "$KEY_ALIAS" 2>/dev/null \
    | grep -m1 'SHA256:' | awk '{print $NF}' | tr -d ':' | tr 'A-F' 'a-f')"
  [ -n "$WANT" ] && [ "$GOT" = "$WANT" ] || { echo "::error::certificate mismatch (apk=$GOT keystore=${WANT:-unreadable})"; exit 1; }
  echo "OK: signed with the release key ($GOT)"
else
  echo "Signing certificate SHA-256: $GOT"
fi

# 3. Alignment (informational): 4 KB zip alignment and 16 KB native-library pages.
ZIPALIGN="${BT}zipalign"
if [ -x "$ZIPALIGN" ]; then
  "$ZIPALIGN" -c 4 "$APK" && echo "zipalign: 4-byte OK" || echo "::warning::APK is not 4-byte zip-aligned"
  "$ZIPALIGN" -c -P 16 4 "$APK" 2>/dev/null && echo "zipalign: 16 KB pages OK" || echo "::warning::native libs are not 16 KB aligned"
fi
