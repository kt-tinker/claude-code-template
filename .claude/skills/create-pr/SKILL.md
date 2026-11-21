---
name: create-pr
description: 現在のブランチの変更をレビューし、チェックを通してから GitHub の Pull Request を作成する。「PR を作って」「プルリクを出して」のような依頼で使う。
allowed-tools: Bash(git status) Bash(git diff:*) Bash(git log:*) Bash(git push:*) Bash(gh pr create:*) Bash(npm run lint) Bash(npm run typecheck) Bash(npm test) Read Grep
---

# Pull Request 作成ワークフロー

## 事前チェック

1. `git status` で未コミットの変更がないか確認する。あればユーザーに確認する
2. 現在のブランチが `main` でないことを確認する
3. `git log main..HEAD --oneline` と `git diff main...HEAD --stat` で変更範囲を把握する

## 品質チェック（すべて通るまで PR を作らない）

- `npm run typecheck`
- `npm run lint`
- `npm test`
- code-reviewer サブエージェントで差分をレビューし、重大な指摘があれば先に直す

## PR の作成

1. `git push -u origin HEAD`
2. 以下の形式で本文を作り、`gh pr create --title "<タイトル>" --body "<本文>"` で作成する
   - タイトルは Conventional Commits 形式（例: `feat: ユーザー検索に絞り込みを追加`）

```markdown
## 概要
<何を・なぜ変更したか。2〜3 文>

## 変更内容
- <主な変更点>

## 確認方法
- [ ] <レビュアーが確認する手順>

## 関連 Issue
Closes #<番号>

## 補足
<影響範囲、破壊的変更、マイグレーションの有無など。なければ削除>
```

3. 作成した PR の URL をユーザーに伝える
