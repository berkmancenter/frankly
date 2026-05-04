#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"

CLIENT_DIR="$REPO_ROOT/client"
DATA_MODELS_DIR="$REPO_ROOT/data_models"
FUNCTIONS_DIR="$REPO_ROOT/firebase/functions"

FVM_FLUTTER_BIN="$CLIENT_DIR/.fvm/flutter_sdk/bin/flutter"
FVM_DART_BIN="$CLIENT_DIR/.fvm/flutter_sdk/bin/dart"

if [ -x "$FVM_FLUTTER_BIN" ] && [ -x "$FVM_DART_BIN" ]; then
  FLUTTER_CMD="$FVM_FLUTTER_BIN"
  DART_CMD="$FVM_DART_BIN"
else
  FLUTTER_CMD="flutter"
  DART_CMD="dart"
fi

flutter_version="$("$FLUTTER_CMD" --version 2>/dev/null || true)"
flutter_version="${flutter_version%%$'\n'*}"
printf '\n[build-all] Using Flutter: %s\n' "$flutter_version"
printf '[build-all] Using Dart: %s\n\n' "$("$DART_CMD" --version 2>&1)"

cd "$CLIENT_DIR"
"$FLUTTER_CMD" pub get

cd "$DATA_MODELS_DIR"
"$FLUTTER_CMD" pub get
"$DART_CMD" run build_runner build --delete-conflicting-outputs

cd "$FUNCTIONS_DIR"
npm install
"$FLUTTER_CMD" pub get
"$DART_CMD" run build_runner build --output=build