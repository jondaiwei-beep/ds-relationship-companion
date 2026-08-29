#!/usr/bin/env bash
# API contract drift gate (M0 exit criterion, Notion 06 §13.2).
#
# Compares the running app's OpenAPI spec against the committed baseline.
# Fails if an endpoint is added or removed without updating the baseline,
# so backend and Flutter DTOs cannot silently diverge.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
BASE_URL="${API_BASE_URL:-http://localhost:8082}"

curl -sf -m 20 "$BASE_URL/v3/api-docs" -o /tmp/live-spec.json \
  || { echo "❌ could not fetch the live spec from $BASE_URL"; exit 1; }

python3 - "$HERE/api-baseline.json" <<'PY'
import json, sys
baseline = json.load(open(sys.argv[1]))
live = json.load(open('/tmp/live-spec.json'))['paths']
live = {p: sorted(m.upper() for m in ops
        if m in ('get','post','put','patch','delete')) for p, ops in live.items()}
# Staging-only endpoints are deliberately EXCLUDED from the contract. They
# must never exist in production, so recording them as part of the API would
# normalise exactly what the profile gate exists to prevent.
live = {p: v for p, v in live.items() if not p.startswith('/v1/staging')}

added   = {p: v for p, v in live.items()     if p not in baseline}
removed = {p: v for p, v in baseline.items() if p not in live}
changed = {p: (baseline[p], live[p]) for p in baseline.keys() & live.keys()
           if baseline[p] != live[p]}

for p, v in added.items():   print(f"  + ADDED   {p} {v}")
for p, v in removed.items(): print(f"  - REMOVED {p} {v}")
for p, (b, l) in changed.items(): print(f"  ~ CHANGED {p}: {b} -> {l}")

if added or removed or changed:
    print("\n❌ API contract drift. Review the change, then refresh the baseline:")
    print("   curl -s $API_BASE_URL/v3/api-docs | python3 -c \"...\" > backend/contract/api-baseline.json")
    sys.exit(1)
print(f"✅ API contract matches baseline ({sum(len(v) for v in live.values())} operations)")
PY
