#!/usr/bin/env bash
# PreToolUse (Bash): 危険なコマンドをブロックする
# stdin に JSON が渡される。exit 2 でブロックし、stderr の内容が Claude に伝わる
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
if ! cmd="$(printf '%s' "$input" | get_json_field '.tool_input.command')"; then
  echo "ブロックしました: hook がコマンドを判定できません（jq か python3 が必要です）。ユーザーに jq のインストール（例: sudo apt install jq）を依頼してください。" >&2
  exit 2
fi

[[ -z "$cmd" ]] && exit 0

# ブロックするパターン（必要に応じて追加）
patterns=(
  'rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*f?[[:space:]]+(/|~|\$HOME)([[:space:]]|$)'  # ルート・ホームの再帰削除
  'git[[:space:]]+push[[:space:]].*(--force|-f)([[:space:]]|$)'                    # force push
  'git[[:space:]]+push[[:space:]]+[^ ]+[[:space:]]+(main|master)([[:space:]]|$)'   # main への直接 push
  'git[[:space:]]+reset[[:space:]]+--hard'                                          # 変更の破棄
  'chmod[[:space:]]+-R[[:space:]]+777'                                              # 過剰な権限付与
  '(curl|wget)[^|]*\|[[:space:]]*(ba|z)?sh'                                         # パイプでのスクリプト実行
  'DROP[[:space:]]+(TABLE|DATABASE)'                                                # DB の削除
)

# 外部コマンド（grep）に頼らず bash の正規表現で判定する（大文字小文字は区別しない）
shopt -s nocasematch
for p in "${patterns[@]}"; do
  if [[ "$cmd" =~ $p ]]; then
    echo "ブロックしました: このコマンドはプロジェクトの hook で禁止されています（パターン: $p）。必要な場合はユーザーに手動での実行を依頼してください。" >&2
    exit 2
  fi
done

exit 0
