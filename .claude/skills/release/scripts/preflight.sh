#!/usr/bin/env bash
# リリース前チェック。1 つでも失敗したら非ゼロで終了する
set -euo pipefail

echo "== ブランチ確認 =="
branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$branch" != "main" ]]; then
  echo "NG: main ブランチでリリースしてください（現在: $branch）" >&2
  exit 1
fi

echo "== 未コミットの変更 =="
if [[ -n "$(git status --porcelain)" ]]; then
  echo "NG: 未コミットの変更があります" >&2
  git status --short >&2
  exit 1
fi

echo "== リモートとの同期 =="
git fetch origin main --quiet
if [[ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ]]; then
  echo "NG: origin/main と一致していません。pull してください" >&2
  exit 1
fi

echo "== 型チェック / Lint / テスト =="
npm run typecheck
npm run lint
npm test

echo "OK: リリースの前提条件を満たしています"
