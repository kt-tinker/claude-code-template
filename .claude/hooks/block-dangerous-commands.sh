#!/usr/bin/env bash
# PreToolUse (Bash): 危険なコマンドをブロックする
# stdin に JSON が渡される。exit 2 でブロックし、stderr の内容が Claude に伝わる
set -euo pipefail

input="$(cat)"
cmd="$(echo "$input" | jq -r '.tool_input.command // empty')"

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

for p in "${patterns[@]}"; do
  if echo "$cmd" | grep -Eiq "$p"; then
    echo "ブロックしました: このコマンドはプロジェクトの hook で禁止されています（パターン: $p）。必要な場合はユーザーに手動での実行を依頼してください。" >&2
    exit 2
  fi
done

exit 0
