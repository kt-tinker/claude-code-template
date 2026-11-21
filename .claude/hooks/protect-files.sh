#!/usr/bin/env bash
# PreToolUse (Edit|Write): 編集してはいけないファイルへの書き込みをブロックする
# exit 2 以外のエラーは「ブロックしない」扱いになるため、判定できないときは exit 2 で安全側に倒す
set -uo pipefail

# JSON からフィールドを取り出す（jq → python3 の順に試す。どちらもなければ 127）
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
if ! file="$(printf '%s' "$input" | get_json_field '.tool_input.file_path')"; then
  echo "ブロックしました: hook が編集対象を判定できません（jq か python3 が必要です）。ユーザーに jq のインストール（例: sudo apt install jq）を依頼してください。" >&2
  exit 2
fi

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
