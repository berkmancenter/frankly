#!/usr/bin/env bash
set -euo pipefail

ports_in_use() {
  # lsof exits 1 on macOS when some (but not all) requested ports have no
  # listeners, even when others do. We check for non-empty output instead of
  # relying on the exit code, but we must capture into a variable first so
  # that pipefail cannot override grep's exit code with lsof's exit code 1.
  local out
  out="$(lsof -nP \
    -iTCP:4400 \
    -iTCP:4000 \
    -iTCP:8080 \
    -iTCP:8085 \
    -iTCP:9000 \
    -iTCP:9099 \
    -iTCP:9150 \
    -iTCP:5001 \
    -sTCP:LISTEN 2>/dev/null || true)"
  [[ -n "$out" ]]
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