#!/bin/bash
# Build the Android release APK against production.
#
# The two --dart-define values are the whole difference between a build that
# talks to production and one that silently points at a dead localhost. They
# are not defaults in the code on purpose: a build has to say where it is
# pointed.
set -euo pipefail

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

echo "API_BASE_URL=$API"
echo "WEB_BASE_URL=$WEB"

flutter build apk --release \
  --dart-define=API_BASE_URL="$API" \
  --dart-define=WEB_BASE_URL="$WEB"

APK=build/app/outputs/flutter-apk/app-release.apk

# The build succeeding does not mean it is pointed anywhere in particular.
# Dart compiles to native, so the host lands in the .so rather than in assets.
echo
echo "--- verifying what was actually baked in"
TMP=$(mktemp -d)
unzip -q -o "$APK" -d "$TMP" 'lib/*'
hits=$(grep -rao "${API#https://}" "$TMP/lib" 2>/dev/null | wc -l | tr -d ' ')
local_hits=$(grep -rao 'localhost:' "$TMP/lib" 2>/dev/null | wc -l | tr -d ' ')
rm -rf "$TMP"

[ "$hits" -gt 0 ] || { echo "FAIL: $API is not in the APK"; exit 1; }
[ "$local_hits" -eq 0 ] || { echo "FAIL: a localhost URL survived into the APK"; exit 1; }

echo "ok: production host present, no localhost"
echo
ls -la "$APK"
