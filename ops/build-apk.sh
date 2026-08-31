#!/bin/bash
# Build the Android release APK against production.
#
# The two --dart-define values are the whole difference between a build that
# talks to production and one that silently points at a dead localhost. They
# are not defaults in the code on purpose: a build has to say where it is
# pointed.
set -euo pipefail

# Resolved before the cd below, or the gate's relative path breaks.
OPS="$(cd "$(dirname "$0")" && pwd)"

cd "$(dirname "$0")/../client"

API="${DS_API_BASE_URL:-https://ds-api.beforeweplay.com}"
WEB="${DS_WEB_BASE_URL:-https://ds-staging.beforeweplay.com}"

# Google publishes API 37 as `platforms;android-37.0`; Gradle looks for
# `android-37`. Without the bridge the build fails with "Failed to find target
# with hash string 'android-37'", which does not say that.
SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-/opt/homebrew/share/android-commandlinetools}}"
if [ -d "$SDK/platforms/android-37.0" ] && [ ! -e "$SDK/platforms/android-37" ]; then
  echo "bridging android-37.0 -> android-37"
  ln -sfn android-37.0 "$SDK/platforms/android-37"
fi

# The gate that was missing. Every bug that reached a real phone — a
# placeholder dynamic id, a dead nav bar, a timezone stub, a lost sign-in
# flow, a dropped deep link, a footer below the fold — passed `flutter test`
# and failed on a device. Set DS_SKIP_DEVICE_VERIFY=1 only when you already
# ran it and know why you are skipping.
if [ "${DS_SKIP_DEVICE_VERIFY:-0}" != "1" ]; then
  bash "$OPS/verify-on-device.sh"
  echo
fi

echo "API_BASE_URL=$API"
echo "WEB_BASE_URL=$WEB"

# Split per ABI. A fat APK carries every architecture's engine and came out
# at 55MB, which is over the limit for handing the file to someone directly.
# arm64 alone is ~19MB and covers every phone made in the last several years.
flutter build apk --release --split-per-abi \
  --dart-define=API_BASE_URL="$API" \
  --dart-define=WEB_BASE_URL="$WEB"

APK=build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

# The build succeeding does not mean it is pointed anywhere in particular.
# Dart compiles to native, so the host lands in the .so rather than in assets.
echo
echo "--- verifying what was actually baked in"
TMP=$(mktemp -d)
# `|| true` on the unzip, not because a failure is acceptable, but because
# unzip returns 1 on a mere warning and `set -e` then killed the script — with
# exit 0, so the whole verification silently never ran. The real check is that
# the .so is on disk afterwards.
unzip -q -o "$APK" -d "$TMP" 'lib/*' || true
[ -d "$TMP/lib" ] || { echo "FAIL: could not read lib/ out of $APK"; exit 1; }

# `|| true` on both greps. Under `set -e` a grep that matches nothing returns
# 1 and kills the script — so the localhost check aborted the run every time
# it PASSED, and the script exited 0 having printed no verdict. A check that
# silently vanishes when it succeeds is worse than no check.
hits=$(grep -rao "${API#https://}" "$TMP/lib" 2>/dev/null | wc -l | tr -d ' ' || true)
local_hits=$(grep -rac 'localhost:' "$TMP/lib" 2>/dev/null | awk -F: '{n+=$NF} END {print n+0}' || true)
rm -rf "$TMP"

[ "$hits" -gt 0 ] || { echo "FAIL: $API is not in the APK"; exit 1; }
[ "$local_hits" -eq 0 ] || { echo "FAIL: a localhost URL survived into the APK"; exit 1; }

echo "ok: production host present, no localhost"
echo
ls -la "$APK"

# --- Android App Links ---------------------------------------------------
#
# `ops/well-known/assetlinks.json` must be served at
# https://<WEB_BASE_URL>/.well-known/assetlinks.json as application/json, or
# Android shows an app chooser instead of opening invite links directly.
#
# It pins the signing certificate's SHA-256. The fingerprint below is the
# DEBUG key, because that is what this build is signed with. A real release
# key means a new fingerprint and a new file — the link silently falls back to
# a chooser otherwise, which looks like a bug and is not one.
#
#   keytool -list -v -keystore ~/.android/debug.keystore \
#     -alias androiddebugkey -storepass android | grep SHA256
#
# Verify after deploying, with Google's own checker rather than by eye:
#
#   curl "https://digitalassetlinks.googleapis.com/v1/statements:list\
# ?source.web.site=https://ds-staging.beforeweplay.com\
# &relation=delegate_permission/common.handle_all_urls"
