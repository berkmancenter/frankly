#!/usr/bin/env bash
set -euo pipefail

HUB_URL="http://127.0.0.1:4400/emulators"

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

wait_for_ports_to_close() {
  local timeout_seconds="${1:-20}"
  local start_time
  start_time="$(date +%s)"

  while true; do
    if ! ports_in_use; then
      return 0
    fi

    local now
    now="$(date +%s)"
    if (( now - start_time >= timeout_seconds )); then
      return 1
    fi

    sleep 0.2
  done
}

echo "Stopping Firebase emulators..."

curl -fsS -X DELETE "$HUB_URL" >/dev/null 2>&1 || true

if wait_for_ports_to_close 20; then
  echo "Firebase emulators stopped cleanly."
  exit 0
fi

echo "Graceful shutdown timed out. Killing only listeners on emulator ports..."

pids="$(lsof -nP -t -iTCP:4400 -iTCP:4000 -iTCP:8080 -iTCP:8085 -iTCP:9000 -iTCP:9099 -iTCP:9150 -iTCP:5001 -sTCP:LISTEN 2>/dev/null | sort -u || true)"

if [ -n "${pids:-}" ]; then
  echo "$pids" | xargs kill >/dev/null 2>&1 || true
fi

if wait_for_ports_to_close 5; then
  echo "Firebase emulators stopped after targeted kill."
  exit 0
fi

echo "Targeted SIGTERM timed out. Sending SIGKILL to remaining emulator listeners..."

pids="$(lsof -nP -t -iTCP:4400 -iTCP:4000 -iTCP:8080 -iTCP:8085 -iTCP:9000 -iTCP:9099 -iTCP:9150 -iTCP:5001 -sTCP:LISTEN 2>/dev/null | sort -u || true)"

if [ -n "${pids:-}" ]; then
  echo "$pids" | xargs kill -9 >/dev/null 2>&1 || true
fi

if wait_for_ports_to_close 3; then
  echo "Firebase emulators stopped after targeted SIGKILL."
  exit 0
fi

echo "Failed to stop all Firebase emulator listeners." >&2
echo "Inspect remaining listeners with:" >&2
echo "  lsof -nP -iTCP:4400 -iTCP:4000 -iTCP:8080 -iTCP:8085 -iTCP:9000 -iTCP:9099 -iTCP:9150 -iTCP:5001 -sTCP:LISTEN" >&2
exit 1