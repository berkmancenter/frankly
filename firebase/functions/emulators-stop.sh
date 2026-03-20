#!/usr/bin/env bash
set -euo pipefail

HUB_URL="http://127.0.0.1:4400/emulators"

# Emulator ports as defined in firebase.json
EMULATOR_PORTS=(4400 4000 8080 8085 9000 9099 9150 5001)

# Convert port array to lsof format (e.g., -iTCP:4400 -iTCP:4000 ...)
format_ports_for_lsof() {
  printf '%s' "${EMULATOR_PORTS[@]/#/-iTCP:}"
}

ports_in_use() {
  # lsof exits 1 on macOS when some (but not all) requested ports have no
  # listeners, even when others do. We check for non-empty output instead of
  # relying on the exit code.
  local out
  out="$(lsof -nP $(format_ports_for_lsof) -sTCP:LISTEN 2>/dev/null || true)"
  [[ -n "$out" ]]
}

kill_listeners() {
  local signal="${1:--}"  # Default to SIGTERM
  local pids
  pids="$(lsof -nP -t $(format_ports_for_lsof) -sTCP:LISTEN 2>/dev/null | sort -u || true)"

  if [ -n "${pids:-}" ]; then
    echo "$pids" | xargs kill $signal >/dev/null 2>&1 || true
  fi
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
kill_listeners "-"

if wait_for_ports_to_close 5; then
  echo "Firebase emulators stopped after targeted kill."
  exit 0
fi

echo "Targeted SIGTERM timed out. Sending SIGKILL to remaining emulator listeners..."
kill_listeners "-9"

if wait_for_ports_to_close 3; then
  echo "Firebase emulators stopped after targeted SIGKILL."
  exit 0
fi

echo "Failed to stop all Firebase emulator listeners." >&2
echo "Inspect remaining listeners with:" >&2
echo "  lsof -nP $(format_ports_for_lsof) -sTCP:LISTEN" >&2
exit 1