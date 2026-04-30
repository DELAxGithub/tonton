#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# agent-callable-check.sh
#
# 自作ツールが AI エージェントから自律操作可能かを監査する。
# .claude/rules/agent-callable.md の要件を最小限チェックする。
#
# Usage:
#   bash agent-callable-check.sh [--target=/path/to/repo] [--json]
#
# Exit code:
#   0 — すべての必須項目を満たす、または対象外（ライブラリのみ）
#   1 — 1 つ以上の要件を満たしていない
#   2 — 引数エラー
# =============================================================================

TARGET="$(pwd)"
OUTPUT_JSON=0

for arg in "$@"; do
  case "$arg" in
    --target=*) TARGET="${arg#*=}" ;;
    --json)     OUTPUT_JSON=1 ;;
    -h|--help)
      sed -n '4,16p' "$0"; exit 0 ;;
    *) echo "unknown arg: $arg" >&2; exit 2 ;;
  esac
done

if [[ ! -d "$TARGET" ]]; then
  echo "[ERROR] target not a directory: $TARGET" >&2
  exit 2
fi

cd "$TARGET"

findings=()
status="pass"

add_finding() {
  # add_finding <severity> <check> <message>
  local severity="$1" check="$2" message="$3"
  findings+=("${severity}|${check}|${message}")
  if [[ "$severity" == "error" ]]; then
    status="fail"
  fi
}

# --- Detect tool type ---
has_cli=0
has_http=0
is_library_only=0

# CLI indicators: bin field in package.json / entry_points in pyproject.toml / executable in scripts/
if [[ -f package.json ]] && grep -qE '"bin"\s*:' package.json; then
  has_cli=1
fi
if [[ -f pyproject.toml ]] && grep -qE '^\s*\[project\.scripts\]' pyproject.toml; then
  has_cli=1
fi
if find . -maxdepth 3 -type f \( -name "cli.ts" -o -name "cli.js" -o -name "cli.py" -o -name "main.py" \) 2>/dev/null | grep -q .; then
  has_cli=1
fi

# HTTP indicators: express/fastapi/hono imports, server files
if grep -rlE "(from ['\"]hono['\"]|from ['\"]express['\"]|from ['\"]fastapi['\"]|FastAPI\(\)|new Hono\(\))" \
    --include="*.ts" --include="*.js" --include="*.py" \
    --exclude-dir=node_modules --exclude-dir=.venv --exclude-dir=dist \
    . 2>/dev/null | head -1 | grep -q .; then
  has_http=1
fi

if [[ $has_cli -eq 0 && $has_http -eq 0 ]]; then
  is_library_only=1
fi

# --- Check 1: README Agent Usage section ---
if [[ -f README.md ]]; then
  if ! grep -qE "^##\s+Agent Usage" README.md; then
    if [[ $is_library_only -eq 0 ]]; then
      add_finding "warn" "readme-agent-usage" "README.md missing '## Agent Usage' section"
    fi
  fi
else
  add_finding "warn" "readme-exists" "README.md not found"
fi

# --- Check 2: CLI --help ---
if [[ $has_cli -eq 1 ]]; then
  cli_cmd=""
  if [[ -f package.json ]]; then
    cli_cmd="$(node -e "const p=require('./package.json'); const b=p.bin; if(typeof b==='string'){console.log(p.name)}else if(b){console.log(Object.keys(b)[0])}" 2>/dev/null || true)"
  fi
  if [[ -n "$cli_cmd" ]]; then
    add_finding "info" "cli-detected" "CLI entry detected: $cli_cmd (manual --help verification recommended)"
  else
    add_finding "info" "cli-detected" "CLI entry detected (manual --help verification recommended)"
  fi
fi

# --- Check 3: OpenAPI spec ---
if [[ $has_http -eq 1 ]]; then
  openapi_found=0
  if grep -rlE "(openapi|swagger)" \
      --include="*.ts" --include="*.js" --include="*.py" \
      --exclude-dir=node_modules --exclude-dir=.venv --exclude-dir=dist \
      . 2>/dev/null | head -1 | grep -q .; then
    openapi_found=1
  fi
  if [[ $openapi_found -eq 0 ]]; then
    add_finding "error" "openapi-spec" "HTTP server detected but no OpenAPI/Swagger reference found"
  else
    add_finding "info" "openapi-detected" "OpenAPI reference found (verify GET /api/openapi.json returns spec)"
  fi
fi

# --- Check 4: rule file present ---
if [[ ! -f .claude/rules/agent-callable.md ]]; then
  add_finding "warn" "rule-file" ".claude/rules/agent-callable.md not installed"
fi

# --- Output ---
if [[ $OUTPUT_JSON -eq 1 ]]; then
  printf '{"status":"%s","target":"%s","is_library_only":%s,"has_cli":%s,"has_http":%s,"findings":[' \
    "$status" "$TARGET" "$is_library_only" "$has_cli" "$has_http"
  first=1
  for f in "${findings[@]:-}"; do
    [[ -z "$f" ]] && continue
    IFS='|' read -r sev chk msg <<< "$f"
    [[ $first -eq 0 ]] && printf ','
    printf '{"severity":"%s","check":"%s","message":"%s"}' "$sev" "$chk" "$msg"
    first=0
  done
  printf ']}\n'
else
  echo "=== agent-callable-check ==="
  echo "  target: $TARGET"
  echo "  CLI:    $([[ $has_cli -eq 1 ]] && echo yes || echo no)"
  echo "  HTTP:   $([[ $has_http -eq 1 ]] && echo yes || echo no)"
  echo "  status: $status"
  echo ""
  if [[ ${#findings[@]} -eq 0 ]]; then
    echo "  (no findings)"
  else
    for f in "${findings[@]}"; do
      IFS='|' read -r sev chk msg <<< "$f"
      printf "  [%-5s] %-25s %s\n" "$sev" "$chk" "$msg"
    done
  fi
fi

[[ "$status" == "pass" ]] && exit 0 || exit 1
