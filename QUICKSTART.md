# 🚀 Menu Stocker クイックスタートガイド

このガイドに従えば、5分で Menu Stocker プロジェクトを立ち上げることができます！

## 📋 前提条件チェック

以下がインストールされていることを確認してください：

- ✅ **Git**
- ✅ **Docker Desktop**
- ✅ (オプション) **Ruby 3.4+**
- ✅ (オプション) **Node.js 20+**

## 📁 プロジェクト構造

```
menu-stocker/
├── apps/                       # アプリケーション
│   ├── backend/               # Rails 8.1 API
│   └── frontend/              # Next.js 16
├── docker/                     # Docker設定
│   ├── backend/               # Backend用Dockerfile
│   └── frontend/              # Frontend用Dockerfile
├── docs/                       # 設計ドキュメント
│   ├── api/                   # API仕様
│   ├── architecture/          # システム設計
│   └── database/              # データベース設計
├── .claude/                    # Claude Code設定
├── .github/                    # GitHub Actions
├── scripts/                    # ユーティリティスクリプト
├── docker-compose.yml          # Docker Compose設定
├── QUICKSTART.md               # このファイル
├── SETUP.md                    # 詳細セットアップ
└── README.md                   # プロジェクト概要
```

## ⚡ セットアップ方法

### Docker セットアップ（推奨）

```bash
# 1. リポジトリをクローン
git clone https://github.com/satoru-tak/Menu-Stocker.git
cd menu-stocker

# 2. 環境変数を設定
cp apps/backend/.env.example apps/backend/.env
cp apps/frontend/.env.example apps/frontend/.env.local

# 3. Docker 環境を起動
docker-compose up -d

# 4. データベースをセットアップ
docker-compose exec backend rails db:create db:migrate

# 5. ブラウザでアクセス
# Backend:  http://localhost:3000
# Frontend: http://localhost:3001
```

### ローカルセットアップ

詳細は [SETUP.md](./SETUP.md) を参照してください。

## 📝 セットアップ後の作業

### 1. 動作確認

```bash
# コンテナの状態を確認
docker-compose ps

# ログを確認
docker-compose logs -f

# Backend API のヘルスチェック
curl http://localhost:3000/health

# Frontend にアクセス
open http://localhost:3001
```

### 2. Claude Code の起動

```bash
# プロジェクトルートで Claude Code を起動
cd menu-stocker
claude
```

### 3. 最初の機能を実装

Claude Code に日本語で指示を出します：

```
ユーザー認証機能を実装してください。
以下の機能を含めてください：
- ユーザー登録
- ログイン
- ログアウト
- 現在のユーザー情報取得

Backend は Devise と JWT を使用し、
Frontend は Next.js の App Router を使用してください。
```

Claude が自動的に：
- ✅ マイグレーションファイルを生成
- ✅ モデルとコントローラーを作成
- ✅ フロントエンドのコンポーネントを作成
- ✅ テストコードを作成
- ✅ 日本語コメントを追加

## 🔧 主要コマンド

### Docker 操作

```bash
# すべてのサービスを起動
docker-compose up -d

# ログを確認
docker-compose logs -f

# 特定のサービスのログ
docker-compose logs -f backend
docker-compose logs -f frontend

# サービスを停止
docker-compose down

# サービスを再起動
docker-compose restart backend
```

### Backend (Rails)

```bash
# コンソール
docker-compose exec backend rails console

# マイグレーション
docker-compose exec backend rails db:migrate

# テスト
docker-compose exec backend rspec

# Lint
docker-compose exec backend rubocop
```

### Frontend (Next.js)

```bash
# 依存関係のインストール
docker-compose exec frontend npm install

# テスト
docker-compose exec frontend npm test

# Lint
docker-compose exec frontend npm run lint
```

## 🐛 トラブルシューティング

### Docker コンテナが起動しない

```bash
# Docker Desktop が起動しているか確認

# コンテナをクリーンアップ
docker-compose down
docker-compose up -d --build
```

### ポートが既に使用されている

```bash
# 使用中のポートを確認（Mac/Linux）
lsof -i :3000
lsof -i :3001

# プロセスを終了
kill -9 <PID>

# または docker-compose.yml のポートを変更
```

### データベースに接続できない

```bash
# データベースコンテナの状態を確認
docker-compose ps db

# データベースのログを確認
docker-compose logs db

# データベースを再作成
docker-compose exec backend rails db:drop db:create db:migrate
```

### Rails または Next.js のインストールエラー

スクリプト実行時に Ruby や Node.js が見つからない場合：

```bash
# Docker を使う場合は、スキップして後で Docker 内で作成可能
# または、ローカルに Ruby と Node.js をインストール
```

## 📚 次のステップ

1. ✅ **ドキュメントを読む**
   - [README.md](./README.md) - プロジェクト概要
   - [SETUP.md](./SETUP.md) - 詳細なセットアップ
   - [docs/architecture/README.md](./docs/architecture/README.md) - アーキテクチャ設計
   - [docs/api/README.md](./docs/api/README.md) - API 仕様

2. ✅ **Claude Code の使い方を学ぶ**
   - [.claude/prompts/templates.md](./.claude/prompts/templates.md) - プロンプト集

3. ✅ **開発を開始**
   - 機能ブランチを作成
   - Claude Code で機能を実装
   - テストを書く
   - Pull Request を作成

## 💡 Tips

### Claude Code の効果的な使い方

1. **具体的に指示する**
   ```
   ❌ 「レシピ機能を作って」
   ✅ 「レシピ作成機能を実装してください。名前、説明、調理時間を入力でき、材料と手順を追加できるようにしてください。」
   ```

2. **段階的に進める**
   ```
   1. モデルとマイグレーション作成
   2. コントローラーと API 実装
   3. フロントエンドのフォーム作成
   4. テスト作成
   ```

3. **日本語で指示**
   ```
   Claude Code は日本語での指示に最適化されています。
   自然な日本語で指示を出してください。
   ```

## ✅ チェックリスト

セットアップが完了したら、以下を確認してください：

- [ ] Docker コンテナが全て起動している
- [ ] Backend API（http://localhost:3000）にアクセスできる
- [ ] Frontend（http://localhost:3001）にアクセスできる
- [ ] データベースが作成されている
- [ ] Claude Code が起動する
- [ ] Git リポジトリが初期化されている

---

**セットアップ完了おめでとうございます！🎉**

開発を楽しんでください！質問があれば、Claude Code に聞いてみてください。
