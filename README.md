# Claude Code プロジェクトテンプレート

Claude Code 公式ドキュメント（`.claude` ディレクトリ / メモリ / スキル / サブエージェント / 設定 / hooks）の推奨構成に沿った、汎用的なひな形です。
`<!-- TODO -->` や `<...>` の箇所を自分のプロジェクトに合わせて書き換えて使います。

## 構成

```
.
├── CLAUDE.md                     # ★ プロジェクト指示（毎セッション読み込み）
├── CLAUDE.local.md.example       #   個人用指示の例 → CLAUDE.local.md にリネーム（gitignore）
├── .mcp.json                     # ★ チーム共有 MCP サーバー
├── .worktreeinclude              # ★ worktree にコピーする gitignore 済みファイル
├── .gitignore                    # ★ Claude Code 関連の除外設定（既存に追記）
├── src/api/CLAUDE.md             # ★ サブディレクトリ用 CLAUDE.md の例
├── .claude/
│   ├── settings.json             # ★ 権限・hooks・環境変数（強制される）
│   ├── settings.local.json.example  # 個人上書きの例 → settings.local.json にリネーム
│   ├── rules/                    # ★ トピック別の指示
│   │   ├── code-style.md         #   常時読み込み
│   │   ├── security.md           #   常時読み込み
│   │   ├── testing.md            #   paths: テストファイルを触るときだけ
│   │   └── frontend.md           #   paths: フロントエンドを触るときだけ
│   ├── skills/                   # ★ 手順・ワークフロー（/name で呼び出し）
│   │   ├── fix-issue/SKILL.md    #   /fix-issue 123
│   │   ├── create-pr/SKILL.md    #   /create-pr
│   │   └── release/              #   /release（Claude からの自動呼び出し禁止）
│   │       ├── SKILL.md
│   │       ├── scripts/preflight.sh
│   │       └── templates/changelog-entry.md
│   ├── agents/                   # ★ サブエージェント
│   │   ├── code-reviewer.md
│   │   ├── test-runner.md
│   │   └── security-auditor.md
│   └── hooks/                    # ★ hook スクリプト（登録は settings.json）
│       ├── block-dangerous-commands.sh
│       ├── protect-files.sh
│       └── format-on-edit.sh
├── user-level-example/           #   ~/.claude/ に置く個人設定の例（リポジトリには含めない）
└── LICENSE                       #   MIT License
    ├── CLAUDE.md
    └── settings.json
```
★ = git にコミットしてチームで共有

## ⚠️ 導入前に読んでください

- **動作確認について**：このテンプレートは公式ドキュメントをもとに作成し、JSON の構文、シェルスクリプトの構文、hook にサンプルを流したときの動きは確認済みです。ただし、実際の Claude Code のセッションに入れての動作確認はしていません。導入後は Claude Code 内で `/hooks`（hook が登録されているか）と `/memory`（指示ファイルが読み込まれているか）を確認してください
- **初回は対話モードで起動して承認してください**：まだ信頼していないフォルダでは、`settings.json` の `permissions.allow` は無視され、`.mcp.json` のサーバーも「承認待ち」になります（Claude Code v2.1.330 で確認）。新しいプロジェクトでは、まず `claude` を対話モードで起動し、フォルダの信頼ダイアログと MCP サーバーの承認を受け入れてください。`claude -p` や CI から使う場合も、事前にこの承認が必要です
- **権限ルールの書き方**：`settings.json` では `Bash(npm test:*)` という書き方を使っています。お使いの Claude Code のバージョンで効かない場合は、`Bash(npm test *)`（末尾がスペースのワイルドカード）を試してください
- **`src/api/CLAUDE.md` はサンプルです**：サブディレクトリに CLAUDE.md を置く書き方の例です。そのままコピーすると `src/api/` ディレクトリが作られるので、使わない場合は削除してください
- **コマンドは TypeScript / npm の例です**：他の言語では `CLAUDE.md`、`settings.json` の `permissions`、`rules/`、`format-on-edit.sh` を書き換えてください
- **hook には `jq` か `python3` が必要です**：hook は JSON の読み取りに `jq` を使い、なければ `python3` を使います。どちらもない環境では、安全のため Bash の実行とファイル編集をすべてブロックします（「判定できない」というメッセージが出ます）。事前に `jq` をインストールしておくのがおすすめです（例: `sudo apt install jq`、`brew install jq`）
  - 背景：hook がエラー（exit 2 以外）で終わると、Claude Code はそれを「ブロックしない」エラーとして扱い、コマンドを実行してしまいます。そのため、判定できないときは exit 2 で止める作りにしています
- **Windows の場合**：hook はシェルスクリプトなので、WSL か Git Bash 上で Claude Code を使うことを想定しています
- **秘密情報の保護は完全ではありません**：`permissions.deny` と hook は誤操作を減らすための仕組みです。秘密情報の管理そのものはシークレットマネージャーなどで行ってください

## 使い方

1. このテンプレートの中身をプロジェクトのルートにコピーする（`user-level-example/`、README、LICENSE は除く）。GitHub の「Use this template」から新しいリポジトリを作ることもできます
2. `CLAUDE.md` の TODO を埋める（まずはここだけで十分）
3. `.claude/settings.json` の `permissions` を、使っている言語・ツールのコマンドに書き換える
4. hook スクリプトに実行権限を付ける：`chmod +x .claude/hooks/*.sh .claude/skills/release/scripts/*.sh`
   - hook は `jq`（なければ `python3`）を使うので、入っていなければ `jq` をインストールする
5. 不要な rules / skills / agents は削除する。足りないものは同じ形式で追加する
6. 個人設定が必要なら `*.example` をリネームする（`.gitignore` 済み）
7. `user-level-example/` の中身は必要に応じて `~/.claude/` にコピーする

動作確認は Claude Code 内で `/memory`（読み込まれている指示ファイル）、`/context`（コンテキストの内訳）、`/hooks`（登録済みの hook）、`/list-agents`（サブエージェント）、`/skills`（スキル）を使います（Claude Code v2.1.330 で確認。`/agents` の画面は廃止されています）。

- `paths:` 付きの rules は、読み込まれても `/memory` の一覧には表示されません。効いているかは、該当するファイルを Claude に編集させたときの振る舞いで確認してください
- 動作確認は `manual mode`（操作のたびに許可を求める標準のモード）で行ってください。`accept edits` や `auto mode` では、確認なしで実行される範囲が変わります

## 書き分けの原則

| 種類 | 置き場所 | 性質 |
|---|---|---|
| 事実・規約・コマンド | `CLAUDE.md` | ガイダンス（常時読み込み） |
| トピック別・パス別の規約 | `.claude/rules/` | ガイダンス（`paths:` で条件付き読み込み） |
| 繰り返す手順 | `.claude/skills/` | 呼び出されたとき・関連するときに読み込み |
| 独立したコンテキストで動かす専門タスク | `.claude/agents/` | 別コンテキストで実行 |
| 必ず守らせたいこと | `settings.json` の `permissions` と `hooks` | **強制される** |

- CLAUDE.md は短く保つ（目安 200 行以内）。長くなったら rules に分けるか、手順なら skills に移す
- 「絶対に〜しない」は CLAUDE.md に書くだけでなく、permissions の deny か hook で強制する
- 定期的に指示ファイルを見直し、古い指示や矛盾する指示を削除する

## 前提

- 例として TypeScript / Node.js（npm）のコマンドを使っています。Python なら `uv run pytest` / `ruff`、Go なら `go test ./...` / `gofmt` などに置き換えてください
- `.claude/commands/` は旧形式（今も動作）のため、このテンプレートでは skills に統一しています
