#!/usr/bin/env bash
# PreToolUse (Read|Edit|Write): 秘密情報の読み書きと、編集してはいけないファイルへの書き込みをブロックする
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
if ! file="$(printf '%s' "$input" | get_json_field '.tool_input.file_path')" \
   || ! tool="$(printf '%s' "$input" | get_json_field '.tool_name')"; then
  echo "ブロックしました: hook が対象のファイルを判定できません（jq か python3 が必要です）。ユーザーに jq のインストール（例: sudo apt install jq）を依頼してください。" >&2
  exit 2
fi

[[ -z "$file" ]] && exit 0

name="${file##*/}"   # ファイル名だけを取り出す（ディレクトリ名に含まれる文字列で誤検知しないように）

# --- 秘密情報：読み取りも書き込みもブロックする ---
is_secret=false
case "$name" in
  .env.example|.env.sample|.env.template) ;;   # 変数名だけを書いた見本ファイルは対象外
  .env|.env.*|*.pem|*.key) is_secret=true ;;
esac
[[ "/$file" == */secrets/* ]] && is_secret=true

if $is_secret; then
  echo "ブロックしました: $file は秘密情報を含む可能性があるファイルです。中身が必要な場合は、ユーザーに確認を依頼してください（必要な変数名は .env.example で確認できます）。" >&2
  exit 2
fi

# --- ここから下は書き込みだけをブロックする（読み取りは許可） ---
[[ "$tool" == "Read" ]] && exit 0

case "$name" in
  package-lock.json|pnpm-lock.yaml|yarn.lock|uv.lock|poetry.lock|go.sum)
    echo "ブロックしました: $file はロックファイルです。依存関係はパッケージマネージャーのコマンドで変更してください。" >&2
    exit 2 ;;
esac

# 保護するディレクトリ（必要に応じて追加）
protected_dirs=(
  '.git/'
  'src/generated/'
  '.github/workflows/'
)

for d in "${protected_dirs[@]}"; do
  if [[ "/$file" == */"$d"* ]]; then
    echo "ブロックしました: $file は保護対象のファイルです（$d）。変更が必要な理由をユーザーに説明し、手動での編集を依頼してください。" >&2
    exit 2
  fi
done

exit 0
