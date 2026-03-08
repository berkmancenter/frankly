#!/usr/bin/env bash
set -euo pipefail

dart run build_runner build --output=build
exec firebase emulators:start --only firestore,functions,auth,pubsub,database --project dev --inspect-functions