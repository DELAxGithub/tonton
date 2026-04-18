#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Agent Harness — safe patch application
# Tries `git apply --3way`, falls back to `patch -p0`.
# =============================================================================

PATCH_FILE="${1:?patch file required}"

if [[ ! -s "$PATCH_FILE" ]]; then
  echo "[ERROR] patch file empty: $PATCH_FILE" >&2
  exit 1
fi

if git apply --check "$PATCH_FILE" 2>/dev/null; then
  git apply "$PATCH_FILE"
  echo "[OK] git apply succeeded"
  exit 0
fi

if git apply --3way "$PATCH_FILE" 2>/dev/null; then
  echo "[OK] git apply --3way succeeded"
  exit 0
fi

echo "[WARN] git apply failed; trying patch -p0"
patch -p0 < "$PATCH_FILE"
