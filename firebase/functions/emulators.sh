#!/usr/bin/env bash
set -euo pipefail

# Read FIREBASE_PROJECT_ID from client/.env (not committed) so the emulator project
# matches what the client uses. Falls back to 'dev' if not found.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLIENT_ENV="$SCRIPT_DIR/../../client/.env"
if [[ ! -f "$CLIENT_ENV" ]]; then
  echo "ERROR: client/.env not found at $CLIENT_ENV" >&2
  echo "Copy client/.env.local.example to client/.env and set FIREBASE_PROJECT_ID." >&2
  exit 1
fi
PROJECT_ID=$(grep -m1 '^FIREBASE_PROJECT_ID=' "$CLIENT_ENV" | sed "s/^FIREBASE_PROJECT_ID=//;s/['\"]//g" || true)
if [[ -z "$PROJECT_ID" ]]; then
  echo "ERROR: FIREBASE_PROJECT_ID is not set in $CLIENT_ENV" >&2
  exit 1
fi

if [[ "${SKIP_DART_BUILD:-}" != "1" ]]; then
  dart run build_runner build --output=build
fi

inspect_flag=()
if [[ "${FRANKLY_DEBUG_FUNCTIONS:-0}" == "1" ]]; then
  inspect_flag=(--inspect-functions)
fi

exec firebase emulators:start \
  --only firestore,functions,auth,pubsub,database \
  --project "$PROJECT_ID" \
  ${inspect_flag:+"${inspect_flag[@]}"}