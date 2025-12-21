# Menu Stocker

レシピを蓄積・管理し、レストランスタイルのメニューとして表示するアプリケーション

## 📖 概要

**Menu Stocker（メニューストッカー）** は、日々のレシピを蓄積（ストック）し、それをレストランのメニューのように美しく表示できるアプリケーションです。

### 主な機能

- 📝 **レシピ管理**: レシピの作成・編集・削除
- 🍽️ **メニュー作成**: 複数のレシピから素敵なメニューを作成
- 📱 **レスポンシブ対応**: PC・タブレット・スマホで快適に使用
- 🎨 **美しい表示**: レストラン風のメニューデザイン

## 🏗️ 技術スタック

### Backend
- **Ruby**: 3.4+
- **Rails**: 8.1+ (API モード)
- **Database**: PostgreSQL 16+
- **Cache/Jobs**: Redis + Sidekiq
- **Authentication**: Devise + JWT

### Frontend
- **Next.js**: 16+ (App Router)
- **React**: 19+
- **TypeScript**: 5+
- **Styling**: Tailwind CSS
- **State**: Zustand / React Query
- **Form**: React Hook Form

### Infrastructure
- **Container**: Docker + Docker Compose
- **CI/CD**: GitHub Actions
- **Deploy**: Vercel (Frontend) + Railway/Render (Backend)

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
│   └── prompts/               # プロンプトテンプレート
├── .github/                    # GitHub Actions
│   └── workflows/             # CI/CD設定
├── scripts/                    # ユーティリティスクリプト
├── docker-compose.yml          # Docker Compose設定
├── CLAUDE.md                   # Claude Code用ガイド
├── README.md                   # このファイル
├── QUICKSTART.md               # クイックスタートガイド
└── SETUP.md                    # 詳細セットアップガイド
```

## 🚀 クイックスタート

### 前提条件

- Docker Desktop
- Git

### セットアップ（5分）

```bash
# 1. リポジトリをクローン
git clone https://github.com/satoru-tak/Menu-Stocker.git
cd menu-stocker

# 2. 環境変数を設定
cp apps/backend/.env.example apps/backend/.env
cp apps/frontend/.env.example apps/frontend/.env.local

# 3. Docker起動
docker-compose up -d

# 4. データベース作成
docker-compose exec backend rails db:create db:migrate

# 5. アクセス
# Backend:  http://localhost:3000
# Frontend: http://localhost:3001
```

詳細は [QUICKSTART.md](./QUICKSTART.md) を参照してください。

## 📚 ドキュメント

- [クイックスタート](./QUICKSTART.md) - 5分で始める
- [セットアップガイド](./SETUP.md) - 詳細な環境構築
- [アーキテクチャ](./docs/architecture/README.md) - システム設計
- [API仕様](./docs/api/README.md) - エンドポイント一覧
- [データベース設計](./docs/database/README.md) - テーブル定義
- [Claude Code使い方](./.claude/prompts/templates.md) - 開発支援

## 🤖 Claude Code で開発

このプロジェクトは Claude Code での開発に最適化されています。

```bash
# Claude Code を起動
cd menu-stocker
claude

# 日本語で指示
「レシピ作成機能を実装してください」
「ユーザー認証を追加してください」
```

Claude が自動的に：
- ✅ コード生成
- ✅ テスト作成
- ✅ 日本語コメント追加
- ✅ ドキュメント更新

## 💻 開発コマンド

### Docker操作

```bash
# サービス起動
docker-compose up -d

# ログ確認
docker-compose logs -f

# サービス停止
docker-compose down

# 再ビルド
docker-compose up -d --build
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
# 依存関係インストール
docker-compose exec frontend npm install

# テスト
docker-compose exec frontend npm test

# Lint
docker-compose exec frontend npm run lint
```

## 🧪 テスト

```bash
# Backend
docker-compose exec backend rspec --format documentation

# Frontend
docker-compose exec frontend npm test -- --coverage
```

## 🌐 デプロイ

- **Frontend**: Vercel に自動デプロイ
- **Backend**: Railway/Render に自動デプロイ

詳細は [.github/workflows/ci.yml](./.github/workflows/ci.yml) を参照

## 📋 開発ガイドライン

### ブランチ戦略

- `main`: 本番環境
- `develop`: 開発環境
- `feature/*`: 新機能
- `fix/*`: バグ修正

### コミット規約

Conventional Commits（日本語）

```bash
feat: 新機能追加
fix: バグ修正
docs: ドキュメント更新
style: コードスタイル変更
refactor: リファクタリング
test: テスト追加・修正
chore: ビルドプロセス変更
```

## 🤝 コントリビューション

1. Fork
2. Feature ブランチ作成 (`git checkout -b feature/amazing-feature`)
3. コミット (`git commit -m 'feat: Add amazing feature'`)
4. Push (`git push origin feature/amazing-feature`)
5. Pull Request 作成

## 📝 ライセンス

MIT License

## 👤 作者

Your Name

---

**Happy Cooking & Coding! 🍳💻**
