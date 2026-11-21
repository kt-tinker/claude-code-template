# <プロジェクト名>

<!-- TODO: 1〜3行でプロジェクトの目的を書く -->
<何を・誰のために・どう提供するか>。

## 技術スタック

<!-- TODO: 実際のスタックに置き換える -->
- 言語: TypeScript 5.x（strict）
- ランタイム: Node.js 22
- フレームワーク: <Next.js / Express / など>
- DB: <PostgreSQL + Prisma など>
- テスト: Vitest（ユニット）、Playwright（E2E）
- パッケージマネージャー: npm（**pnpm / yarn は使わない**）

## よく使うコマンド

```bash
npm install            # 依存関係のインストール
npm run dev            # 開発サーバー起動
npm run build          # ビルド
npm run lint           # Lint（ESLint）
npm run typecheck      # 型チェック
npm test               # ユニットテスト全件
npm test -- <path>     # 単一ファイルのテスト（全件より先にこちらを使う）
npm run test:e2e       # E2E テスト
```

## ディレクトリ構成

<!-- TODO: 主要ディレクトリだけ書く。全ファイルを列挙しない -->
- `src/app/` — 画面・ルーティング
- `src/api/` — API ハンドラ（詳細は `src/api/CLAUDE.md`）
- `src/lib/` — 共通ロジック。UI に依存しないコードはここに置く
- `src/components/` — 再利用 UI コンポーネント
- `tests/` — テスト（`src/` と同じ構成でミラーする）
- `docs/` — 設計ドキュメント・ADR

## 開発ワークフロー

1. 実装前に関連コードと既存テストを読み、方針を短く説明してから着手する
2. 変更は小さく保つ。1 つのタスクで無関係なリファクタリングをしない
3. 変更後は `npm run typecheck` → `npm run lint` → 関連テストの順で確認する
4. コミットは Conventional Commits 形式（`feat:` `fix:` `docs:` `refactor:` `test:` `chore:`）
5. ブランチ名: `feat/<issue番号>-<短い説明>`、`fix/<issue番号>-<短い説明>`
6. `main` に直接コミット・push しない

## 規約（詳細は `.claude/rules/` を参照）

- コードスタイル: `.claude/rules/code-style.md`
- セキュリティ: `.claude/rules/security.md`
- テスト: `.claude/rules/testing.md`（テストファイルを触るときに自動で読み込まれる）
- フロントエンド: `.claude/rules/frontend.md`（UI ファイルを触るときに自動で読み込まれる）

## 注意事項・ハマりどころ

<!-- TODO: プロジェクト固有の「知らないと失敗すること」を書く。ここが一番価値がある -->
- 環境変数は `.env.example` を参照。`.env` は読まない・編集しない
- DB スキーマを変更したら `npx prisma migrate dev --name <name>` でマイグレーションを作る（スキーマ直接編集だけで終わらせない）
- `src/generated/` は自動生成コード。手で編集しない
- <例: 外部 API X はレート制限が厳しいので、テストではモックを使う>

## 参照ドキュメント

<!-- 必要なときだけ読ませたい資料は @ で取り込まず、パスだけ書いておく -->
- アーキテクチャ概要: `docs/architecture.md`
- API 仕様: `docs/api.md`
