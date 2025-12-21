# 📦 Menu Stocker - 設定ファイル一式

Menu Stocker プロジェクトをすぐに始められる設定ファイル一式です。

## 🎯 プロジェクト名について

**Menu Stocker（メニューストッカー）** = レシピを「蓄積（ストック）」して「メニュー」として表示

このプロジェクト構成は、`apps/` ディレクトリ配下に `backend` と `frontend` を配置する、業界標準のモノレポ構造を採用しています。

## 📁 このアーカイブの内容

```
files/
├── setup/                      # セットアップ用
│   ├── init_project.sh        # 🚀 初期化スクリプト（重要！）
│   └── .gitignore             # Git除外設定
├── docker/                     # Docker設定
│   ├── docker-compose.yml     # Docker Compose定義
│   ├── backend.Dockerfile     # Rails用Dockerfile
│   └── frontend.Dockerfile    # Next.js用Dockerfile
├── claude/                     # Claude Code設定
│   ├── settings.json          # 基本設定（日本語対応）
│   ├── rules.md               # 開発ルール
│   └── prompts.md             # プロンプト集
├── docs/                       # 設計ドキュメント
│   ├── architecture.md        # アーキテクチャ設計
│   ├── database.md            # DB設計（ER図含む）
│   └── api.md                 # API仕様書
├── github/                     # GitHub Actions
│   └── ci.yml                 # CI/CD設定
├── HOW_TO_USE.md              # 📖 詳しい使い方（必読！）
├── README.md                   # プロジェクト概要
├── QUICKSTART.md              # クイックスタート
├── SETUP.md                   # 詳細セットアップ
└── STRUCTURE_COMPARISON.md    # 構造の説明
```

**全17ファイル** が含まれています。

## 🚀 最速セットアップ（5分）

### 1. ダウンロードしたファイルを配置

```bash
# プロジェクトディレクトリを作成
mkdir menu-stocker
cd menu-stocker

# ダウンロードしたアーカイブを展開
tar -xzf menu-stocker-files.tar.gz
# または
unzip menu-stocker-files.zip

# 確認
ls files/
```

### 2. 初期化スクリプトを実行

```bash
bash files/setup/init_project.sh
```

画面の指示に従ってください：
- Rails プロジェクト作成: **Y**
- Next.js プロジェクト作成: **Y**
- Git 初期化: **Y**

### 3. 環境変数を設定

```bash
cp apps/backend/.env.example apps/backend/.env
cp apps/frontend/.env.example apps/frontend/.env.local
```

### 4. Docker起動

```bash
docker-compose up -d
```

### 5. データベース作成

```bash
docker-compose exec backend rails db:create db:migrate
```

### 6. アクセス確認

- **Backend API**: http://localhost:3000
- **Frontend**: http://localhost:3001

## 📖 ドキュメント

詳しい使い方は以下を参照してください：

1. **HOW_TO_USE.md** - このファイルの使い方（最初に読む）
2. **QUICKSTART.md** - 5分で始める方法
3. **README.md** - プロジェクト詳細
4. **SETUP.md** - 詳細なセットアップ手順
5. **STRUCTURE_COMPARISON.md** - プロジェクト構造の説明

## 🎨 最終的なプロジェクト構造

初期化後は以下のような構造になります：

```
menu-stocker/
├── files/                      # 設定ファイル（保管用）
├── apps/                       # アプリケーション
│   ├── backend/               # Rails API
│   └── frontend/              # Next.js
├── .claude/                    # Claude Code設定
├── docs/                       # 設計ドキュメント
├── docker/                     # Docker設定
│   ├── backend/
│   └── frontend/
├── .github/                    # GitHub Actions
│   └── workflows/
├── docker-compose.yml
├── .gitignore
└── README.md
```

`files/` ディレクトリは設定ファイルのマスターコピーとして保管されます。

## 🤖 Claude Code で開発

このプロジェクトは Claude Code での開発に最適化されています。

```bash
# Claude Code を起動
cd menu-stocker
claude

# 日本語で指示を出すだけ
「ユーザー認証機能を実装してください」
「レシピ作成フォームを作成してください」
```

Claude が自動的に：
- ✅ コード生成
- ✅ テスト作成
- ✅ 日本語コメント追加
- ✅ ドキュメント更新

## 💡 プロジェクト名を変更したい場合

`menu-stocker` を別の名前に変更したい場合：

```bash
cd files
find . -type f -exec sed -i 's/menu-stocker/your-project/g' {} +
find . -type f -exec sed -i 's/menu_stocker/your_project/g' {} +
find . -type f -exec sed -i 's/Menu Stocker/Your Project/g' {} +
```

## ✅ セットアップ完了の確認

以下が全てYesになればOKです：

- [ ] Docker コンテナが全て起動している（`docker-compose ps`）
- [ ] Backend API にアクセスできる（http://localhost:3000）
- [ ] Frontend にアクセスできる（http://localhost:3001）
- [ ] `apps/backend/` に Rails プロジェクトがある
- [ ] `apps/frontend/` に Next.js プロジェクトがある
- [ ] Claude Code が起動する（`claude`）

## 🐛 トラブルシューティング

### Docker が起動しない

```bash
# Docker Desktop が起動しているか確認
docker-compose down
docker-compose up -d --build
```

### ポートが使用されている

```bash
# 使用中のポートを確認
lsof -i :3000
lsof -i :3001

# docker-compose.yml でポート番号を変更
```

### Ruby / Node.js がない

Docker を使用すれば、ローカルに Ruby や Node.js をインストールする必要はありません。

## 📚 技術スタック

### Backend
- Ruby 3.3+
- Rails 8.0+ (API mode)
- PostgreSQL 16+
- Redis + Sidekiq

### Frontend
- Next.js 15+ (App Router)
- React 19+
- TypeScript 5+
- Tailwind CSS

### Infrastructure
- Docker + Docker Compose
- GitHub Actions
- Vercel (Frontend) + Railway/Render (Backend)

## 🤝 サポート

質問や問題がある場合：

1. `files/HOW_TO_USE.md` を確認
2. `files/QUICKSTART.md` のトラブルシューティングを確認
3. Claude Code に聞いてみる（`claude` コマンドで起動）

---

**Happy Coding! 🚀**

レシピを蓄積して、素敵なメニューを作りましょう！
