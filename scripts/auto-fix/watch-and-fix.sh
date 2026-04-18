#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Agent Harness — local watch mode
# Uses fswatch (macOS) or inotifywait (Linux) to re-run auto-build-fix
# whenever files change. Debounces to avoid thrashing.
# =============================================================================

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUILD_SCRIPT="$PROJECT_DIR/scripts/auto-fix/auto-build-fix.sh"
DEBOUNCE_SECONDS="${DEBOUNCE_SECONDS:-3}"

WATCH_DIRS=("${@:-$PROJECT_DIR}")

if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
  echo "[ERROR] ANTHROPIC_API_KEY not set" >&2
  exit 1
fi

echo "[WATCH] watching: ${WATCH_DIRS[*]}"
echo "[WATCH] debounce: ${DEBOUNCE_SECONDS}s"

last=0
trigger() {
  local now; now=$(date +%s)
  if (( now - last < DEBOUNCE_SECONDS )); then return; fi
  last=$now
  echo "[WATCH] change detected — running build..."
  bash "$BUILD_SCRIPT" || echo "[WATCH] build failed, will retry on next change"
}

if command -v fswatch >/dev/null 2>&1; then
  fswatch -o "${WATCH_DIRS[@]}" | while read -r _; do trigger; done
elif command -v inotifywait >/dev/null 2>&1; then
  while inotifywait -r -e modify,create,delete,move "${WATCH_DIRS[@]}"; do trigger; done
else
  echo "[ERROR] install fswatch (macOS: brew install fswatch) or inotify-tools (linux)" >&2
  exit 1
fi
