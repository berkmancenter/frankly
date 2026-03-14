#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR" && pwd)"

CLIENT_DIR="$REPO_ROOT/client"
DATA_MODELS_DIR="$REPO_ROOT/data_models"
FUNCTIONS_DIR="$REPO_ROOT/firebase/functions"

STAMP_DIR="$REPO_ROOT/.local/dev-stamps"
mkdir -p "$STAMP_DIR"

DATA_MODELS_STAMP="$STAMP_DIR/data_models_build.stamp"
FUNCTIONS_STAMP="$STAMP_DIR/functions_build.stamp"

EMULATOR_PID=""

log() {
  printf '\n[run-dev] %s\n' "$*"
}

require_dir() {
  local dir="$1"
  if [ ! -d "$dir" ]; then
    echo "Required directory not found: $dir" >&2
    exit 1
  fi
}

need_flutter_pub_get() {
  [ ! -f ".dart_tool/package_config.json" ] || \
  [ "pubspec.yaml" -nt ".dart_tool/package_config.json" ] || \
  { [ -f "pubspec.lock" ] && [ "pubspec.lock" -nt ".dart_tool/package_config.json" ]; }
}

need_npm_install() {
  [ ! -d "node_modules" ] || \
  [ ! -f "node_modules/.package-lock.stamp" ] || \
  [ "package.json" -nt "node_modules/.package-lock.stamp" ] || \
  { [ -f "package-lock.json" ] && [ "package-lock.json" -nt "node_modules/.package-lock.stamp" ]; }
}

mark_npm_install() {
  mkdir -p node_modules
  touch node_modules/.package-lock.stamp
}

need_data_models_build() {
  [ ! -f "$DATA_MODELS_STAMP" ] || \
  find \
    "$DATA_MODELS_DIR/lib" \
    "$DATA_MODELS_DIR/build.yaml" \
    "$DATA_MODELS_DIR/pubspec.yaml" \
    "$DATA_MODELS_DIR/pubspec.lock" \
    -type f -newer "$DATA_MODELS_STAMP" 2>/dev/null | grep -q .
}

need_functions_build() {
  [ ! -f "$FUNCTIONS_STAMP" ] || \
  find \
    "$FUNCTIONS_DIR/lib" \
    "$FUNCTIONS_DIR/node" \
    "$FUNCTIONS_DIR/test" \
    "$FUNCTIONS_DIR/build.yaml" \
    "$FUNCTIONS_DIR/pubspec.yaml" \
    "$FUNCTIONS_DIR/pubspec.lock" \
    "$FUNCTIONS_DIR/package.json" \
    "$FUNCTIONS_DIR/package-lock.json" \
    "$FUNCTIONS_DIR/emulators.sh" \
    "$FUNCTIONS_DIR/emulators-start.sh" \
    "$FUNCTIONS_DIR/emulators-stop.sh" \
    -type f -newer "$FUNCTIONS_STAMP" 2>/dev/null | grep -q .
}

wait_for_port() {
  local port="$1"
  local timeout="${2:-30}"
  local deadline=$(( SECONDS + timeout ))

  while true; do
    if lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
      return 0
    fi

    if (( SECONDS >= deadline )); then
      echo "Timed out waiting for port $port" >&2
      return 1
    fi

    sleep 0.2
  done
}

cleanup() {
  local exit_code=$?

  if [ -n "${EMULATOR_PID:-}" ] && kill -0 "$EMULATOR_PID" >/dev/null 2>&1; then
    log "Stopping emulators..."
    (
      cd "$FUNCTIONS_DIR"
      ./emulators-stop.sh >/dev/null 2>&1 || true
    )
  fi

  exit "$exit_code"
}

trap cleanup EXIT INT TERM

require_dir "$CLIENT_DIR"
require_dir "$DATA_MODELS_DIR"
require_dir "$FUNCTIONS_DIR"

log "Repo root: $REPO_ROOT"

log "Checking client Dart dependencies..."
cd "$CLIENT_DIR"
if need_flutter_pub_get; then
  log "Running flutter pub get in client..."
  flutter pub get
else
  log "Client dependencies unchanged; skipping flutter pub get."
fi

log "Checking data_models Dart dependencies..."
cd "$DATA_MODELS_DIR"
if need_flutter_pub_get; then
  log "Running flutter pub get in data_models..."
  flutter pub get
else
  log "data_models dependencies unchanged; skipping flutter pub get."
fi

if need_data_models_build; then
  log "Rebuilding data_models..."
  dart run build_runner build --delete-conflicting-outputs
  touch "$DATA_MODELS_STAMP"
else
  log "data_models unchanged; skipping build_runner."
fi

log "Checking functions JS dependencies..."
cd "$FUNCTIONS_DIR"
if need_npm_install; then
  log "Running npm install in firebase/functions..."
  npm install
  mark_npm_install
else
  log "Functions node_modules unchanged; skipping npm install."
fi

log "Checking functions Dart dependencies..."
if need_flutter_pub_get; then
  log "Running flutter pub get in firebase/functions..."
  flutter pub get
else
  log "Functions Dart dependencies unchanged; skipping flutter pub get."
fi

if need_functions_build; then
  log "Rebuilding firebase/functions..."
  dart run build_runner build --output=build
  touch "$FUNCTIONS_STAMP"
else
  log "firebase/functions unchanged; skipping build_runner."
fi

log "Resetting and starting emulators..."
cd "$FUNCTIONS_DIR"
chmod +x ./emulators.sh ./emulators-start.sh ./emulators-stop.sh
(./emulators-stop.sh || true) >/dev/null 2>&1
SKIP_DART_BUILD=1 ./emulators-start.sh &
EMULATOR_PID=$!

log "Waiting for emulators to become ready..."
wait_for_port 8080 30
wait_for_port 5001 30

log "Launching Flutter client..."
cd "$CLIENT_DIR"
flutter run \
  -d chrome \
  --web-renderer html \
  -t lib/dev_emulators_main.dart \
  --dart-define-from-file=.env