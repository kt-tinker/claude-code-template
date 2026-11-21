---
name: release
description: バージョン番号を上げて CHANGELOG を更新し、リリース用のタグを作成する。
argument-hint: <patch|minor|major>
disable-model-invocation: true
---

# リリースワークフロー

このスキルはユーザーが `/release <patch|minor|major>` と明示的に実行したときだけ使う（Claude から自動では呼び出さない）。

リリース種別: $ARGUMENTS

## 手順

1. **事前チェック**
   - `bash .claude/skills/release/scripts/preflight.sh` を実行する
   - 失敗したら中止し、理由をユーザーに伝える

2. **変更内容を集める**
   - `git describe --tags --abbrev=0` で前回のタグを取得する
   - `git log <前回タグ>..HEAD --oneline` でコミットを一覧にする
   - Conventional Commits のプレフィックスで分類する（feat → 追加、fix → 修正、その他 → 変更）

3. **バージョンを上げる**
   - `npm version $ARGUMENTS --no-git-tag-version`

4. **CHANGELOG を更新する**
   - `templates/changelog-entry.md` の形式で `CHANGELOG.md` の先頭に追記する
   - 内容をユーザーに見せて確認をとる

5. **コミットとタグ**
   - `git add package.json package-lock.json CHANGELOG.md`
   - `git commit -m "chore(release): v<新バージョン>"`
   - `git tag v<新バージョン>`

6. **push はユーザーの確認後に行う**
   - `git push && git push --tags` を実行してよいか確認する
