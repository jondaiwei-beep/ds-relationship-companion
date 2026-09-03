#!/bin/bash
# Run the app on a real device runtime before handing anyone a build.
#
# Every bug the owner found on their phone was invisible to `flutter test`: a
# placeholder dynamic id the server rejected, a nav bar that swallowed taps, a
# timezone lookup that was `return null`, a magic-link flow held in memory, a
# deep link dropped, a legal footer below the fold. None lived in a screen, so
# no screen test could fail on them.
#
# This is the gate that was missing. Run it before every APK.
set -euo pipefail

cd "$(dirname "$0")/../client"

API="${DS_API_BASE_URL:-https://ds-api.beforeweplay.com}"
WEB="${DS_WEB_BASE_URL:-https://ds-staging.beforeweplay.com}"

# The simulator, booting it if it is not already up. iOS runs the same `_io`
# code path as Android — the platform channels differ, the Dart does not.
# Prefer one that is already booted; otherwise boot the first available.
SIM=$(xcrun simctl list devices booted -j 2>/dev/null \
  | python3 -c 'import json,sys
d=json.load(sys.stdin)["devices"]
print(next((x["udid"] for v in d.values() for x in v), ""))')

if [ -z "$SIM" ]; then
  SIM=$(xcrun simctl list devices available -j \
    | python3 -c 'import json,sys
d=json.load(sys.stdin)["devices"]
print(next((x["udid"] for k,v in d.items() if "iOS" in k for x in v), ""))')
  [ -n "$SIM" ] || { echo "FAIL: no iOS simulator available"; exit 1; }
  xcrun simctl boot "$SIM"
  xcrun simctl bootstatus "$SIM" -b >/dev/null
fi

echo "running the first-run journey on $SIM"
flutter test integration_test/first_run_test.dart -d "$SIM" \
  --dart-define=API_BASE_URL="$API" \
  --dart-define=WEB_BASE_URL="$WEB"

echo
echo "ok: a new person can register and reach a screen they can act on"

echo "running the two-person full loop on $SIM"
flutter test integration_test/full_loop_test.dart -d "$SIM" \
  --dart-define=API_BASE_URL="$API" \
  --dart-define=WEB_BASE_URL="$WEB"

echo
echo "ok: D and s ran the core loop end to end (pair, task, deliver, praise, points, record, inbox, safeword)"
