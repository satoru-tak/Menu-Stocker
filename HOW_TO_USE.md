# 📦 Menu Stocker 設定ファイルの使い方

このディレクトリには、Menu Stocker プロジェクトをセットアップするための全ファイルが含まれています。

## 📁 ディレクトリ構造

```
files/
├── setup/                      # セットアップ用
│   ├── init_project.sh        # 🚀 初期化スクリプト（これを実行！）
│   └── .gitignore             # Git除外設定
├── docker/                     # Docker設定
│   ├── docker-compose.yml     # Docker Compose定義
│   ├── backend.Dockerfile     # Backend用Dockerfile
│   └── frontend.Dockerfile    # Frontend用Dockerfile
├── claude/                     # Claude Code設定
│   ├── settings.json          # Claude基本設定
│   ├── rules.md               # 開発ルール
│   └── prompts.md             # プロンプトテンプレート
├── docs/                       # 設計ドキュメント
│   ├── architecture.md        # システムアーキテクチャ
│   ├── database.md            # データベース設計
│   └── api.md                 # API仕様書
├── github/                     # GitHub Actions
│   └── ci.yml                 # CI/CD設定
├── README.md                   # プロジェクト概要
├── QUICKSTART.md              # クイックスタート（5分で開始）
├── SETUP.md                   # 詳細セットアップガイド
├── STRUCTURE_COMPARISON.md    # 構造の説明
└── HOW_TO_USE.md              # このファイル
```

## 🎯 想定される使用方法

### パターン1: 新規プロジェクト作成

```bash
# 1. プロジェクトディレクトリを作成
mkdir menu-stocker
cd menu-stocker

# 2. このディレクトリ（files）をダウンロード・配置
# ダウンロードしたファイルを menu-stocker/files/ に配置

# 3. 初期化スクリプトを実行
bash files/setup/init_project.sh

# 4. 環境変数を設定
cp apps/backend/.env.example apps/backend/.env
cp apps/frontend/.env.example apps/frontend/.env.local

# 5. Docker起動
docker-compose up -d

# 6. データベース作成
docker-compose exec backend rails db:create db:migrate

# 完了！
```

### パターン2: 既存プロジェクトに設定を追加

```bash
# 既存の menu-stocker プロジェクトに移動
cd menu-stocker

# files/ ディレクトリをコピー
# ダウンロードしたファイルを配置

# 必要な設定ファイルを個別にコピー
cp files/docker/docker-compose.yml .
cp files/claude/settings.json .claude/
cp files/docs/api.md docs/api/README.md

# など、必要なファイルのみ選択的にコピー
```

## 🚀 最速セットアップ（5分）

### 前提条件
- Docker Desktop がインストール済み
- Git がインストール済み

### 手順

```bash
# 1. プロジェクトディレクトリを作成して移動
mkdir menu-stocker && cd menu-stocker

# 2. このディレクトリを配置
#   ダウンロードした files/ を menu-stocker/ 配下に配置

# 3. 以下のコマンドを実行
bash files/setup/init_project.sh

# 画面の指示に従って:
# - Rails プロジェクト作成: Y
# - Next.js プロジェクト作成: Y
# - Git 初期化: Y

# 4. 環境変数を設定
cp apps/backend/.env.example apps/backend/.env
cp apps/frontend/.env.example apps/frontend/.env.local

# 5. Docker 起動
docker-compose up -d

# 6. データベース作成
docker-compose exec backend rails db:create db:migrate

# 完了！以下にアクセス
# Backend:  http://localhost:3000
# Frontend: http://localhost:3001
```

## 📋 各ファイルの役割

### 🔧 setup/

**init_project.sh**
- プロジェクト全体を自動で初期化するスクリプト
- files/ 配下の設定を適切な場所に展開
- Rails と Next.js のプロジェクト作成
- Git リポジトリの初期化

**使用方法:**
```bash
bash files/setup/init_project.sh
```

**.gitignore**
- Git で管理しないファイル・ディレクトリの定義
- 環境変数、ログ、一時ファイルなどを除外

### 🐳 docker/

**docker-compose.yml**
- 全サービス（PostgreSQL、Redis、Backend、Frontend、Sidekiq）の定義
- 開発環境の構築

**backend.Dockerfile**
- Rails API 用の Docker イメージ定義

**frontend.Dockerfile**
- Next.js 用の Docker イメージ定義

### 🤖 claude/

**settings.json**
- Claude Code の基本設定
- プロジェクト情報、技術スタック、言語設定

**rules.md**
- 開発ルールとコーディング規約
- Git 運用ルール、ディレクトリ構造など

**prompts.md**
- Claude Code に指示を出す際のテンプレート集
- 機能実装、バグ修正、リファクタリングなど

### 📚 docs/

**architecture.md**
- システム全体のアーキテクチャ設計
- レイヤー構成、データフロー、セキュリティ設計

**database.md**
- データベース設計（ER図、テーブル定義）
- マイグレーション戦略、インデックス設計

**api.md**
- API エンドポイントの仕様
- リクエスト/レスポンス例、エラーハンドリング

### ⚙️ github/

**ci.yml**
- GitHub Actions の CI/CD 設定
- テスト、Lint、デプロイの自動化

## 💡 よくある質問

### Q1: files/ ディレクトリは削除していいですか？

**A:** いいえ、保持することを推奨します。

- プロジェクトを再初期化する際のテンプレートとして機能
- 設定ファイルのマスターコピーとして保管
- Git で管理することで設定の履歴を追跡

### Q2: 一部の設定だけ使いたい場合は？

**A:** 必要なファイルだけコピーしてください。

```bash
# 例: Docker 設定だけ使う
cp files/docker/docker-compose.yml .
cp -r files/docker/*.Dockerfile docker/

# 例: Claude 設定だけ使う
mkdir -p .claude
cp files/claude/* .claude/
```

### Q3: プロジェクト名を変更したい場合は？

**A:** 各ファイル内の `menu-stocker`、`menu_stocker`、`Menu Stocker` を一括置換してください。

```bash
# 例: my-app に変更
cd files
find . -type f -exec sed -i 's/menu-stocker/my-app/g' {} +
find . -type f -exec sed -i 's/menu_stocker/my_app/g' {} +
find . -type f -exec sed -i 's/Menu Stocker/My App/g' {} +
```

### Q4: Ruby や Node.js がインストールされていない場合は？

**A:** Docker を使用すれば、ローカルに Ruby や Node.js をインストールする必要はありません。

```bash
# 初期化スクリプト実行時に Rails/Next.js 作成をスキップ
# その後、Docker 内で作成可能

docker-compose run --rm backend rails new . --api --database=postgresql
docker-compose run --rm frontend npx create-next-app@latest .
```

### Q5: エラーが発生した場合は？

**A:** QUICKSTART.md のトラブルシューティングセクションを参照してください。

主なエラーと対処法：
- ポート使用中: docker-compose.yml でポート番号を変更
- Docker 起動失敗: `docker-compose down && docker-compose up -d --build`
- データベース接続エラー: `docker-compose logs db` で原因を確認

## 📖 推奨する読む順番

1. **まずこのファイル（HOW_TO_USE.md）** - 全体像を把握
2. **QUICKSTART.md** - 5分で始める
3. **README.md** - プロジェクト詳細を理解
4. **SETUP.md** - 詳細なセットアップ方法
5. **docs/** - 設計を理解して開発開始

## 🎓 学習リソース

### プロジェクト構造について
- [STRUCTURE_COMPARISON.md](./STRUCTURE_COMPARISON.md) - apps/ 配下構造の説明

### Claude Code について
- [claude/rules.md](./claude/rules.md) - 開発ルール
- [claude/prompts.md](./claude/prompts.md) - プロンプト集

### アーキテクチャについて
- [docs/architecture.md](./docs/architecture.md) - システム設計
- [docs/database.md](./docs/database.md) - DB設計
- [docs/api.md](./docs/api.md) - API仕様

## ✅ セットアップ完了の確認

以下が全てYesになればセットアップ完了です：

- [ ] `docker-compose ps` で全コンテナが起動中
- [ ] `curl http://localhost:3000/health` が成功
- [ ] `http://localhost:3001` にアクセスできる
- [ ] `apps/backend/` に Rails プロジェクトがある
- [ ] `apps/frontend/` に Next.js プロジェクトがある
- [ ] `.claude/` に Claude 設定がある
- [ ] `docs/` にドキュメントがある

---

**セットアップの準備ができました！🎉**

次は [QUICKSTART.md](./QUICKSTART.md) を読んで、プロジェクトを開始しましょう！
