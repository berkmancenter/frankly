#!/usr/bin/env bash
set -euo pipefail

ports_in_use() {
  lsof -nP \
    -iTCP:4400 \
    -iTCP:4000 \
    -iTCP:8080 \
    -iTCP:8085 \
    -iTCP:9000 \
    -iTCP:9099 \
    -iTCP:9150 \
    -iTCP:5001 \
    -sTCP:LISTEN >/dev/null 2>&1
}

if ports_in_use; then
  echo
  echo "Firebase emulator ports are already in use."
  echo
  echo "Run:"
  echo "  ./emulators-stop.sh"
  echo
  echo "Then retry:"
  echo "  ./emulators-start.sh"
  echo
  echo "See dev.md -> Firebase emulator recovery"
  echo
  exit 1
fi

exec ./emulators.sh