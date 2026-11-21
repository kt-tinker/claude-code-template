#!/usr/bin/env bash
# PostToolUse (Edit|Write): 編集したファイルを自動フォーマットする
# フォーマットは補助的な処理なので、失敗しても作業は止めない（常に exit 0）
set -uo pipefail

# JSON からフィールドを取り出す（jq → python3 の順に試す）
get_json_field() {
  if command -v jq >/dev/null 2>&1; then
    jq -r "$1 // empty"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c '
import json, sys
d = json.load(sys.stdin)
for k in sys.argv[1].strip(".").split("."):
    d = d.get(k) if isinstance(d, dict) else None
print(d if isinstance(d, str) else "")' "$1"
  else
    return 127
  fi
}

input="$(cat)"
file="$(printf '%s' "$input" | get_json_field '.tool_input.file_path' 2>/dev/null)" || exit 0

[[ -z "$file" || ! -f "$file" ]] && exit 0

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

case "$file" in
  *.ts|*.tsx|*.js|*.jsx|*.json|*.css|*.md)
    npx --no-install prettier --write "$file" >/dev/null 2>&1 || true
    ;;
  *.py)
    command -v ruff >/dev/null && ruff format "$file" >/dev/null 2>&1 || true
    ;;
  *.go)
    command -v gofmt >/dev/null && gofmt -w "$file" >/dev/null 2>&1 || true
    ;;
esac

exit 0
