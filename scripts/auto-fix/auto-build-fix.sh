#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Agent Harness — generic auto-build-fix core
#
# Runs BUILD_COMMAND in a loop. If it fails, captures the output, asks Claude
# to propose a patch, applies it (via safe-patch-apply.sh), and retries.
#
# BUILD_COMMAND can be set via env or read from auto-fix-config.yml.
# Patch generation is delegated to claude-patch-generator.sh.
# Source: generalized from delax100daysworkout/scripts/auto-fix-scripts/.
# =============================================================================

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONFIG_FILE="${PROJECT_DIR}/scripts/auto-fix/auto-fix-config.yml"
ERROR_DIR="${PROJECT_DIR}/.auto-fix"
BUILD_LOG="${ERROR_DIR}/build.log"
ERROR_FILE="${ERROR_DIR}/errors.txt"
PATCH_FILE="${ERROR_DIR}/patch.diff"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-5}"

mkdir -p "$ERROR_DIR"

# --- Logging ---
log_info()  { echo "[INFO]  $1"; }
log_error() { echo "[ERROR] $1" >&2; }
log_ok()    { echo "[OK]    $1"; }

# --- Load build command ---
if [[ -z "${BUILD_COMMAND:-}" ]] && [[ -f "$CONFIG_FILE" ]]; then
  BUILD_COMMAND=$(grep -E '^\s*command:' "$CONFIG_FILE" | head -1 | sed 's/.*command:[[:space:]]*"//;s/"[[:space:]]*$//')
fi

if [[ -z "${BUILD_COMMAND:-}" ]]; then
  log_error "BUILD_COMMAND not set (env or auto-fix-config.yml)"
  exit 1
fi

log_info "Build command: $BUILD_COMMAND"
log_info "Max attempts:  $MAX_ATTEMPTS"

# --- Main loop ---
attempt=0
while (( attempt < MAX_ATTEMPTS )); do
  attempt=$((attempt + 1))
  log_info "Attempt $attempt/$MAX_ATTEMPTS: running build..."

  if bash -c "$BUILD_COMMAND" > "$BUILD_LOG" 2>&1; then
    log_ok "Build succeeded on attempt $attempt"
    exit 0
  fi

  log_error "Build failed. Extracting errors..."
  # Generic error extraction: grab lines containing 'error' (variant-specific
  # extractors can override by placing extract-errors.sh next to this script)
  if [[ -x "$(dirname "$0")/extract-errors.sh" ]]; then
    "$(dirname "$0")/extract-errors.sh" "$BUILD_LOG" > "$ERROR_FILE"
  else
    grep -iE "error:|failed|exception" "$BUILD_LOG" | head -80 > "$ERROR_FILE" || true
  fi

  if [[ ! -s "$ERROR_FILE" ]]; then
    log_error "No errors extracted from build log — aborting"
    tail -40 "$BUILD_LOG"
    exit 1
  fi

  log_info "Asking Claude for a patch..."
  if [[ -x "$(dirname "$0")/claude-patch-generator.sh" ]]; then
    "$(dirname "$0")/claude-patch-generator.sh" "$ERROR_FILE" "$PATCH_FILE"
  else
    log_error "claude-patch-generator.sh not found — stub only"
    exit 1
  fi

  if [[ ! -s "$PATCH_FILE" ]]; then
    log_error "Claude returned empty patch — aborting"
    exit 1
  fi

  log_info "Applying patch..."
  if [[ -x "$(dirname "$0")/safe-patch-apply.sh" ]]; then
    "$(dirname "$0")/safe-patch-apply.sh" "$PATCH_FILE"
  else
    git apply --3way "$PATCH_FILE"
  fi
done

log_error "Exhausted $MAX_ATTEMPTS attempts without green build"
exit 1
