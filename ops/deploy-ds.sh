#!/bin/bash
# =============================================================
# deploy-ds.sh — build & deploy the D/s Companion backend
#                (independent app: port 8082, database `dsapp`)
#
# Isolation from xmatch (see docs/adr/ADR-0002):
#   - JDK:      /opt/jdk21/bin/java   (xmatch A/B stay on system JDK 8)
#   - Port:     8082                  (A=8080, B=8081)
#   - Database: dsapp                 (NOT sdm_pro / sdm_pro_b)
#   - Jar:      dsapp.jar
#   - Build:    /opt/applications/dsapp/build
#   - Backups:  /opt/backups/dsapp
#
# Nothing here touches xmatch's alternatives, JAVA_HOME, jars or databases.
#
# Usage:  bash ~/deploy-ds.sh
# =============================================================
set -uo pipefail

APP_DIR="/opt/applications/dsapp"
GIT_REPO="${DS_GIT_REPO:-git@github.com:JonDai/dsapp.git}"
BRANCH="${DS_BRANCH:-main}"
BUILD_DIR="$APP_DIR/build"
JAR="$APP_DIR/dsapp.jar"
NEW_JAR="$APP_DIR/new-dsapp.jar"
ENV_FILE="$APP_DIR/dsapp.env"
PORT=8082
LOG="$APP_DIR/app.log"
BACKUP_DIR="/opt/backups/dsapp"
STARTUP_TIMEOUT=120
MAX_BACKUPS=5

# ADR-0002 H-3: 512m heap, same profile as the B instance.
JAVA_BIN="/opt/jdk21/bin/java"
JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Duser.timezone=UTC"

mkdir -p "$BUILD_DIR" "$BACKUP_DIR"

log(){ echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }
file_md5(){ [ -f "$1" ] && md5sum "$1" | awk '{print $1}' || echo "MISSING"; }

# Match ONLY our process. Never touches dating.jar / dating-b.jar.
find_pids(){ pgrep -f "dsapp\.jar"; }

# ---- 0. Preflight ----
log "===== dsapp deploy start (branch=$BRANCH) ====="
[ -x "$JAVA_BIN" ] || { log "ERROR: $JAVA_BIN missing. Install Temurin 21 to /opt/jdk21."; exit 1; }
JV=$("$JAVA_BIN" -version 2>&1 | head -1)
log "JDK: $JV"
[ -f "$ENV_FILE" ] || { log "ERROR: $ENV_FILE missing (DB_URL/DB_USER/DB_PASSWORD)"; exit 1; }

# ---- 1. Fetch source ----
if [ -d "$BUILD_DIR/.git" ]; then
  cd "$BUILD_DIR"
  git fetch origin || { log "ERROR: git fetch failed"; exit 1; }
  git reset --hard "origin/$BRANCH" || { log "ERROR: git reset origin/$BRANCH failed"; exit 1; }
  git clean -fd
else
  log "first clone..."
  rm -rf "${BUILD_DIR:?}/"* 2>/dev/null || true
  git clone "$GIT_REPO" -b "$BRANCH" "$BUILD_DIR" || { log "ERROR: clone failed"; exit 1; }
  cd "$BUILD_DIR"
fi

SHA=$(git rev-parse --short HEAD)
# Guard: refuse to build anything other than the intended branch.
if [ "$SHA" != "$(git rev-parse --short "origin/$BRANCH")" ]; then
  log "ERROR: HEAD is not origin/$BRANCH — refusing to build"; exit 1
fi
log "source: branch=$BRANCH commit=$SHA"

# ---- 2. Build ----
log "building (gradle bootJar)..."
cd "$BUILD_DIR/backend"
export JAVA_HOME="/opt/jdk21"
if ! ./gradlew bootJar --no-daemon -q; then
  log "ERROR: gradle build failed"; log "===== deploy FAILED (build) ====="; exit 1
fi

BUILT=$(find "$BUILD_DIR/backend/build/libs" -maxdepth 1 -name "*.jar" ! -name "*-plain.jar" | head -1)
[ -n "$BUILT" ] || { log "ERROR: no jar produced"; exit 1; }
cp "$BUILT" "$NEW_JAR"
NEW_MD5=$(file_md5 "$NEW_JAR")
log "built: $BUILT -> $NEW_JAR (md5=$NEW_MD5)"

# ---- 3. Back up current jar (enables rollback) ----
BK=""
if [ -f "$JAR" ]; then
  BK="$BACKUP_DIR/dsapp_$(date +%Y%m%d%H%M%S).jar"
  cp "$JAR" "$BK" && log "backed up: $BK"
  ls -t "$BACKUP_DIR/dsapp_"*.jar 2>/dev/null | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm
fi

# ---- 4. Swap ----
mv "$NEW_JAR" "$JAR" || { log "ERROR: jar swap failed"; exit 1; }
[ "$(file_md5 "$JAR")" = "$NEW_MD5" ] || { log "ERROR: md5 mismatch after swap"; exit 1; }

# ---- 5. Stop old process ----
OLD=$(find_pids || true)
if [ -n "$OLD" ]; then
  log "stopping old PID(s): $OLD"
  for p in $OLD; do kill "$p" 2>/dev/null || true; done
  for i in $(seq 1 30); do [ -z "$(find_pids || true)" ] && break; sleep 1; done
  for p in $(find_pids || true); do log "force kill $p"; kill -9 "$p" 2>/dev/null || true; done
  for i in $(seq 1 15); do ss -tln 2>/dev/null | grep -q ":$PORT" || break; sleep 1; done
fi

start_app(){
  cd "$APP_DIR"
  set -a; . "$ENV_FILE"; set +a
  nohup "$JAVA_BIN" $JAVA_OPTS -jar "$JAR" --server.port=$PORT > "$LOG" 2>&1 &
  echo $!
}

# ---- 6. Start + health check ----
NEW=$(start_app)
log "started PID=$NEW, waiting up to ${STARTUP_TIMEOUT}s..."

for i in $(seq 1 $STARTUP_TIMEOUT); do
  if ! ps -p "$NEW" >/dev/null 2>&1; then
    log "ERROR: process exited immediately"; tail -30 "$LOG"
    # ---- automatic rollback ----
    if [ -n "$BK" ]; then
      log "ROLLING BACK to $BK"
      cp "$BK" "$JAR" && RB=$(start_app) && log "rolled back, PID=$RB"
    fi
    exit 1
  fi
  code=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:$PORT/actuator/health" 2>/dev/null || echo 000)
  if [ "$code" = "200" ]; then
    log "===== dsapp deploy OK (commit=$SHA port=$PORT md5=$NEW_MD5) ====="
    log "NOTE: health 200 means the process is alive — still verify business behaviour."
    exit 0
  fi
  sleep 1
done

log "ERROR: startup timeout"; tail -30 "$LOG"
if [ -n "$BK" ]; then
  log "ROLLING BACK to $BK"
  for p in $(find_pids || true); do kill -9 "$p" 2>/dev/null || true; done
  cp "$BK" "$JAR" && RB=$(start_app) && log "rolled back, PID=$RB"
fi
exit 1
