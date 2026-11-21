#!/usr/bin/env bash
# PreToolUse (Edit|Write): 編集してはいけないファイルへの書き込みをブロックする
set -euo pipefail

input="$(cat)"
file="$(echo "$input" | jq -r '.tool_input.file_path // empty')"

[[ -z "$file" ]] && exit 0

# 保護するパス（必要に応じて追加）
protected=(
  '.env'
  '.env.'
  'secrets/'
  '.git/'
  'package-lock.json'
  'src/generated/'
  '.github/workflows/'
)

for p in "${protected[@]}"; do
  if [[ "$file" == *"$p"* ]]; then
    echo "ブロックしました: $file は保護対象のファイルです（$p）。変更が必要な理由をユーザーに説明し、手動での編集を依頼してください。" >&2
    exit 2
  fi
done

exit 0
