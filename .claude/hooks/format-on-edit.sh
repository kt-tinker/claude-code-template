#!/usr/bin/env bash
# PostToolUse (Edit|Write): 編集したファイルを自動フォーマットする
# 失敗しても作業は止めない（exit 0）
set -uo pipefail

input="$(cat)"
file="$(echo "$input" | jq -r '.tool_input.file_path // empty')"

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
