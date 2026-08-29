#!/usr/bin/env bash
# Verifies V1 migration applies cleanly and its constraints enforce the product red lines.
# Usage: PGPORT=5433 ./backend/verify_schema.sh
set -euo pipefail
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
PORT="${PGPORT:-5433}"; DB=dsapp_schema_verify
HERE="$(cd "$(dirname "$0")" && pwd)"

psql -p "$PORT" -U postgres -d postgres -qc "DROP DATABASE IF EXISTS $DB;" >/dev/null
psql -p "$PORT" -U postgres -d postgres -qc "CREATE DATABASE $DB;" >/dev/null

echo "→ applying all migrations"
for m in "$HERE"/src/main/resources/db/migration/V*.sql; do
  psql -p "$PORT" -U postgres -d "$DB" -v ON_ERROR_STOP=1 -q -f "$m"
done
echo "✅ migrations apply cleanly"

echo "→ verifying constraints reject invalid writes"
psql -p "$PORT" -U postgres -d "$DB" -f "$HERE/src/test/resources/schema_constraints_test.sql" \
  >/dev/null 2>/tmp/verify.err || true
n=$(grep -c "^psql.*ERROR" /tmp/verify.err || true)
if [ "$n" -ne 6 ]; then
  echo "❌ expected 6 constraint rejections, got $n"; cat /tmp/verify.err; exit 1
fi
grep -q "append-only" /tmp/verify.err || { echo "❌ append-only trigger not enforced"; exit 1; }
echo "✅ V1: 6 constraints enforce (append-only x2, membership, invite, outbox dedupe, discuss-blocks-duplicate)"

echo "→ verifying auth single-use + rotation constraints"
psql -p "$PORT" -U postgres -d "$DB" -f "$HERE/src/test/resources/auth_constraints_test.sql" \
  >/tmp/verify2.out 2>/tmp/verify2.err || true
a=$(grep -c "^psql.*ERROR" /tmp/verify2.err || true)
[ "$a" -eq 2 ] || { echo "❌ expected 2 auth rejections, got $a"; cat /tmp/verify2.err; exit 1; }
grep -q "^UPDATE 1" /tmp/verify2.out || { echo "❌ magic link consume did not succeed once"; exit 1; }
grep -q "^UPDATE 0" /tmp/verify2.out || { echo "❌ magic link was consumable twice — SINGLE USE BROKEN"; exit 1; }
echo "✅ V2: magic link is single-use; one active refresh token per session"
psql -p "$PORT" -U postgres -d postgres -qc "DROP DATABASE IF EXISTS $DB;" >/dev/null
