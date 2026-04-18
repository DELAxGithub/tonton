#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Agent Harness — Claude patch generator (stub/reference impl)
#
# Takes an error report, calls Claude via anthropic SDK, writes a unified diff.
# Override per-project if you need repo-specific context injection.
# =============================================================================

ERROR_FILE="${1:?error file required}"
PATCH_FILE="${2:?patch output path required}"

if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
  echo "[ERROR] ANTHROPIC_API_KEY not set" >&2
  exit 1
fi

python3 - <<'PY' "$ERROR_FILE" "$PATCH_FILE"
import os
import sys
from anthropic import Anthropic

error_file, patch_file = sys.argv[1], sys.argv[2]
with open(error_file) as f:
    errors = f.read()

client = Anthropic()
msg = client.messages.create(
    model=os.environ.get("CLAUDE_MODEL", "claude-sonnet-4-6"),
    max_tokens=4096,
    messages=[{
        "role": "user",
        "content": (
            "Build failed with the following errors. Propose a minimal unified "
            "diff patch (git apply format) to fix them. Output ONLY the diff, "
            "no prose, no code fences.\n\n" + errors
        ),
    }],
)

text = "".join(block.text for block in msg.content if getattr(block, "type", "") == "text")
# Strip accidental code fences
if text.startswith("```"):
    text = text.split("\n", 1)[1].rsplit("```", 1)[0]

with open(patch_file, "w") as f:
    f.write(text.strip() + "\n")

print(f"[OK] patch written: {patch_file}")
PY
