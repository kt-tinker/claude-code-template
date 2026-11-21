---
name: fix-issue
description: GitHub の Issue 番号を受け取り、内容の確認から原因調査、テストを含む修正、コミットまでを行う。「Issue #123 を直して」「この issue に対応して」のような依頼で使う。
argument-hint: <issue番号>
allowed-tools: Bash(gh issue view:*) Bash(git switch:*) Bash(git add:*) Bash(git commit:*) Read Grep Glob Edit Write
---

# Issue 修正ワークフロー

対象 Issue: #$ARGUMENTS

## 手順

1. **Issue を読む**
   - `gh issue view $ARGUMENTS --json number,title,body,labels,comments` で本文とコメントを確認する
     - `--json` で取得する項目を指定する。`--comments` だけだと、GitHub 側の Projects (classic) 廃止に関するエラーで失敗することがある
   - 期待する動作・実際の動作・再現手順を 3 行で要約してユーザーに示す
   - 内容が曖昧なら、着手前に質問する

2. **ブランチを作る**
   - `git switch -c fix/$ARGUMENTS-<短い説明>`

3. **原因を調べる**
   - 関連コードを Grep / Glob で探し、原因の仮説を立てる
   - 仮説と修正方針を短く説明する

4. **再現テストを書く**
   - 修正前に失敗するテストを書き、実際に失敗することを確認する

5. **修正する**
   - 最小限の変更で直す。無関係なリファクタリングはしない

6. **確認する**
   - 追加したテストが通ること
   - `npm run typecheck` と `npm run lint` が通ること
   - 関連するテストファイルがすべて通ること

7. **コミットする**
   - メッセージ: `fix: <要約> (#$ARGUMENTS)`
   - push と PR 作成は行わず、ユーザーに `/create-pr` を案内する

## 完了時の報告

- 原因（1〜2 文）
- 変更したファイルと変更内容
- 追加したテスト
- 残っている懸念点があればそれも
