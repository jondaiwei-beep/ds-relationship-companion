#!/usr/bin/env bash
# Render every approved SCR-01 state through a real browser with the bundled
# fonts, and store the result beside its design.
#
#   ./tool/qa/render-scr01.sh
#
# flutter test ships no fonts, so an in-harness toImage() renders every glyph
# as a filled box. Only a browser render is evidence about typography.
set -euo pipefail

cd "$(dirname "$0")/../.."
OUT="design/qa/implementation/SCR-01"
PORT=8099
mkdir -p "$OUT"

STATES=(standard empty solo loading offline authorizationLost)

cleanup() { kill %1 2>/dev/null || true; }
trap cleanup EXIT

for state in "${STATES[@]}"; do
  echo "── $state"
  (cd client && flutter build web \
      --target lib/qa_today_main.dart \
      --dart-define=state="$state" \
      --release >/dev/null)

  (cd client/build/web && python3 -m http.server "$PORT" >/dev/null 2>&1) &
  sleep 2

  # Headless Chrome's --window-size is not the CSS viewport: content wider
  # than the window is clipped rather than laid out at 390dp, which reads as a
  # layout bug that is not there. Playwright sets a real viewport.
  echo "  serve http://localhost:$PORT/ and capture with Playwright"

  kill %1 2>/dev/null || true
  wait %1 2>/dev/null || true
done

cat <<'NOTE'

Each state was built and served in turn. Capture with Playwright at a 390x844
viewport, scale "device", and save into design/qa/implementation/SCR-01/.

Verify no state exceeds the viewport first:

    cd client && flutter test test/features/today_viewport_test.dart
NOTE
