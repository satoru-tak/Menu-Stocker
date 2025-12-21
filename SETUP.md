# 開発環境セットアップガイド

## 1. 前提条件

以下のツールがインストールされていることを確認してください：

### 必須
- **Git**: バージョン管理
- **Docker Desktop**: コンテナ環境
  - Windows/Mac: [Docker Desktop](https://www.docker.com/products/docker-desktop/)
  - Linux: Docker Engine + Docker Compose
- **Visual Studio Code**: エディタ（推奨）
  - 拡張機能: Ruby, Rails, ESLint, Prettier

### 推奨（ローカル開発用）
- **Node.js**: 20.x LTS
- **Ruby**: 3.4.x
- **PostgreSQL**: 16.x（Docker を使用する場合は不要）

## 2. プロジェクトのクローン

```bash
# リポジトリをクローン
git clone https://github.com/yourusername/menu-stocker.git
cd menu-stocker

# ブランチ構造を確認
git branch -a
```

## 3. Docker 環境のセットアップ

### 3.1 環境変数ファイルの作成

```bash
# Backend 用の .env ファイル
cp apps/backend/.env.example apps/backend/.env

# Frontend 用の .env ファイル
cp apps/frontend/.env.example apps/frontend/.env.local
```

### 3.2 環境変数の設定

**apps/backend/.env**
```bash
# Database
DATABASE_HOST=db
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=password
DATABASE_NAME=menu_stocker_development

# Redis
REDIS_URL=redis://redis:6379/0

# JWT
JWT_SECRET_KEY=your-secret-key-here-change-in-production

# Rails
RAILS_ENV=development
RAILS_LOG_TO_STDOUT=true
```

**apps/frontend/.env.local**
```bash
# API URL
NEXT_PUBLIC_API_URL=http://localhost:3000/api/v1

# その他の設定
NEXT_PUBLIC_APP_NAME=Menu Stocker
```

### 3.3 Docker イメージのビルド

```bash
# すべてのサービスをビルド
docker-compose build

# 特定のサービスのみビルド
docker-compose build backend
docker-compose build frontend
```

### 3.4 コンテナの起動

```bash
# すべてのサービスを起動（デタッチモード）
docker-compose up -d

# ログを確認
docker-compose logs -f

# 特定のサービスのログを確認
docker-compose logs -f backend
docker-compose logs -f frontend
```

### 3.5 データベースのセットアップ

```bash
# データベースの作成
docker-compose exec backend rails db:create

# マイグレーションの実行
docker-compose exec backend rails db:migrate

# シードデータの投入
docker-compose exec backend rails db:seed
```

## 4. ローカル環境のセットアップ（Docker を使わない場合）

### 4.1 Backend (Rails)

```bash
cd apps/backend

# 依存パッケージのインストール
bundle install

# データベースのセットアップ
rails db:create db:migrate db:seed

# サーバーの起動
rails server -p 3000
```

### 4.2 Frontend (Next.js)

```bash
cd apps/frontend

# 依存パッケージのインストール
npm install
# または
yarn install

# 開発サーバーの起動
npm run dev
# または
yarn dev
```

## 5. 動作確認

### 5.1 アクセス確認

- **Backend API**: http://localhost:3000
  - ヘルスチェック: http://localhost:3000/health
  - API ドキュメント: http://localhost:3000/api-docs
  
- **Frontend**: http://localhost:3001
  - ホームページ: http://localhost:3001

### 5.2 API テスト

```bash
# ヘルスチェック
curl http://localhost:3000/health

# ユーザー登録テスト
curl -X POST http://localhost:3000/api/v1/users/sign_up \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "password": "password123",
      "password_confirmation": "password123"
    }
  }'
```

## 6. テストの実行

### 6.1 Backend テスト

```bash
# すべてのテストを実行
docker-compose exec backend rspec

# 特定のテストを実行
docker-compose exec backend rspec spec/models/recipe_spec.rb

# カバレッジレポートを生成
docker-compose exec backend rspec --format documentation
```

### 6.2 Frontend テスト

```bash
# すべてのテストを実行
docker-compose exec frontend npm test

# ウォッチモード
docker-compose exec frontend npm test -- --watch

# カバレッジレポートを生成
docker-compose exec frontend npm test -- --coverage
```

## 7. コードの品質チェック

### 7.1 Backend (Rubocop)

```bash
# すべてのファイルをチェック
docker-compose exec backend rubocop

# 自動修正
docker-compose exec backend rubocop -a

# 特定のファイルをチェック
docker-compose exec backend rubocop app/models/recipe.rb
```

### 7.2 Frontend (ESLint & Prettier)

```bash
# ESLint チェック
docker-compose exec frontend npm run lint

# ESLint 自動修正
docker-compose exec frontend npm run lint:fix

# Prettier チェック
docker-compose exec frontend npm run format:check

# Prettier 自動修正
docker-compose exec frontend npm run format
```

## 8. データベース操作

### 8.1 マイグレーション

```bash
# 新しいマイグレーションを作成
docker-compose exec backend rails g migration AddCategoryToRecipes category:string

# マイグレーションを実行
docker-compose exec backend rails db:migrate

# マイグレーションをロールバック
docker-compose exec backend rails db:rollback

# 特定のバージョンまでロールバック
docker-compose exec backend rails db:migrate:down VERSION=20231221120000
```

### 8.2 コンソール

```bash
# Rails コンソールを起動
docker-compose exec backend rails console

# データベースコンソールを起動
docker-compose exec backend rails dbconsole

# PostgreSQL に直接接続
docker-compose exec db psql -U postgres -d menu_stocker_development
```

### 8.3 データのリセット

```bash
# データベースをリセット（開発環境のみ）
docker-compose exec backend rails db:reset

# データベースを削除して再作成
docker-compose exec backend rails db:drop db:create db:migrate db:seed
```

## 9. トラブルシューティング

### 9.1 コンテナが起動しない

```bash
# コンテナの状態を確認
docker-compose ps

# ログを確認
docker-compose logs

# コンテナを再起動
docker-compose restart

# コンテナを停止して削除し、再ビルド
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### 9.2 ポートが既に使用されている

```bash
# 使用中のポートを確認（Mac/Linux）
lsof -i :3000
lsof -i :3001

# プロセスを終了
kill -9 <PID>

# または docker-compose.yml のポートを変更
```

### 9.3 データベース接続エラー

```bash
# データベースコンテナの状態を確認
docker-compose ps db

# データベースのログを確認
docker-compose logs db

# データベースを再起動
docker-compose restart db
```

### 9.4 依存パッケージの更新

```bash
# Backend
docker-compose exec backend bundle update

# Frontend
docker-compose exec frontend npm update
```

## 10. 便利なコマンド集

### 10.1 よく使うコマンド

```bash
# すべてのコンテナを起動
docker-compose up -d

# すべてのコンテナを停止
docker-compose down

# コンテナに入る
docker-compose exec backend bash
docker-compose exec frontend sh

# ログを監視
docker-compose logs -f backend frontend

# データベースのバックアップ
docker-compose exec db pg_dump -U postgres menu_stocker_development > backup.sql

# データベースの復元
docker-compose exec -T db psql -U postgres menu_stocker_development < backup.sql
```

### 10.2 クリーンアップ

```bash
# 停止中のコンテナを削除
docker-compose down

# ボリュームも含めて削除
docker-compose down -v

# 未使用のイメージを削除
docker image prune -a

# すべての Docker リソースを削除（注意！）
docker system prune -a --volumes
```

## 11. エディタの設定

### 11.1 VS Code

推奨拡張機能:
```json
{
  "recommendations": [
    "rebornix.ruby",
    "Shopify.ruby-lsp",
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "bradlc.vscode-tailwindcss",
    "ms-azuretools.vscode-docker"
  ]
}
```

設定ファイル (.vscode/settings.json):
```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "[ruby]": {
    "editor.defaultFormatter": "Shopify.ruby-lsp"
  },
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  ]
}
```

## 12. 次のステップ

セットアップが完了したら：

1. [CLAUDE_RULES.md](./CLAUDE_RULES.md) で開発ルールを確認
2. [docs/](./docs/) で設計ドキュメントを確認
3. 機能ブランチを作成して開発開始
4. テストを書いてから実装（TDD）
5. Pull Request を作成してレビュー依頼

---

**困ったときは**: GitHub Issues でサポートを受けられます
