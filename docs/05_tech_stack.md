# 技術要件定義書

> このプロジェクトを「どんな技術で・どう動かすか」を確定する文書。
> 関連文書：`01_vision.md` / `02_requirements.md` / `03_data_model.md` / `04_api_design.md`

---

## 0. 位置づけと方針

- 技術スタックは、先行プロジェクト **anime-manga-manager と揃える**。規約（`.claude/rules/`）・スキル（`/start-issue`・`/ship`・`/project-review`・`/handover`）・Makefile・CIをほぼそのまま流用し、Claude Codeが自分の誤りに機械的に気づける仕組み（ハーネス）と、検証が通るまで直し続けるループを最短で動かすため
- 第1段階で**使わないものは入れない**（認証・権限・外部ジョブキュー・クライアント側の状態管理ライブラリなど）。入っていると、Claude Codeが「使うものだ」と判断して実装に混ぜる原因になるため。必要になった段階で入れる
- 2025年12月時点の土台（`apps/backend`・`apps/frontend`）はモデル・画面の実装がない段階のため、**作り直す**（`rails new`・Next.js初期化からやり直し、anime-manga-managerのMakefile・CI・規約を移植する）

---

## 1. システム構成

### 1-1. 構成の考え方：APIは1つ、DBも1つ、画面は複数

```text
  Web（Next.js）       ─┐
                        ├─→  Rails API（1つ） ─→ PostgreSQL（1つ）
  スマホアプリ（将来）  ─┘
```

- スマホアプリは「サービス」ではなく、Webと同じく **APIを呼ぶ画面（クライアント）の1つ**として扱う
- **マイクロサービスにはしない**。業務ごとにAPIを分けると、運用・監視・データ整合性の負担が増え、今の規模では負担の方が大きいため
- **DBはAPI（サービス）ごとに1つ**が基本。APIが1つなのでDBも1つ。分割を検討するのは、サービス自体を分けたときか、負荷対策で読み込み専用の複製を足すとき
- 写真は第1段階ではローカル（Active Storageのディスク保存）。公開版ではクラウドのストレージ（S3など）に置く（Active Storageの設定切り替えで対応）

### 1-2. 拡張性のために守ること

1. **APIを画面の都合に合わせない**：Next.js専用の形にせず、どの画面からでも使える形にする（`/api/v1`でバージョン管理）
2. **API仕様は自動生成する**：rspec-openapiで生成した仕様から、Web・スマホの型を作れるようにする
3. **ルールはAPI側に集める**：分量の換算・バージョンの扱い・定番の解決などの計算を画面側に書かない
4. **企業モードは「組織」で拡張する**（`03_data_model.md`の将来の拡張を参照）

### 1-3. リポジトリ構成：モノレポ

- バックエンド・Web・（将来の）スマホアプリを**1つのリポジトリ**で管理する。APIの変更と画面の修正を1つのPRにまとめられ、API仕様から生成した型を共有でき、規約・CI・Claude Codeの設定を1か所で管理できるため
- リポジトリを分けるのは、チームが分かれて別々のペースで開発・リリースするようになったとき

---

## 2. 技術選定

### 2-1. バックエンド：Ruby on Rails（APIモード）

- `rails new backend --api` で作成（Rails 8.1系の最新、Ruby 3.4系の最新）
- 型チェックに **Steep** を使い、型は **RBS** で書く。`app/`の型はインラインRBS、モデルの型は **rbs_rails**、gemの型は **rbs collection** で用意する
  - 理由：テスト・lintに加えて、実行前に誤り（`nil`考慮漏れ・引数違いなど）を機械的に検出するため（ハーネスの一部）
- JSONの組み立ては **Alba**
- API仕様書（OpenAPI）は **rspec-openapi** でrequest specから生成し、`backend/doc/openapi.yaml`としてコミットする。設計意図の正は`04_api_design.md`
- テストは **RSpec**＋**FactoryBot**。カバレッジは **SimpleCov**（行＋分岐）で計測し、基準値を下回るとCIを落とす
- lint・セキュリティは **RuboCop（Rails Omakase）**・**Brakeman**・**bundler-audit**
- 画像は **Active Storage**＋**image_processing**（アップロード時に表示用サイズへ縮小・圧縮）
- バックグラウンド処理が必要になった場合は、Rails標準の **Solid Queue** を使う（Sidekiq・Redisは使わない）
- **第1段階では入れないもの**：devise・devise-jwt（認証）、pundit（権限）、sidekiq（ジョブキュー）

### 2-2. フロントエンド：Next.js（React）

- **Next.js（App Router）**＋**TypeScript**（strict）＋**Tailwind CSS**
- データ取得はServer Componentsを基本にし、フォームは **React Hook Form**＋**zod**
- テストは **Vitest**＋**Testing Library**＋**MSW**（APIのモック）
- lintは **ESLint**＋`tsc --noEmit`
- **第1段階では入れないもの**：React Query、Zustand、axios（必要になった時点で検討する）

### 2-3. データベース：PostgreSQL

- PostgreSQL 16系。Railsでのデファクトであること、データ整合性の厳格さ、JSON型・全文検索などの拡張性から選ぶ

### 2-4. スマホでの利用（検討中・未確定）

- 第1段階はWeb（レスポンシブ、スマホ優先）で使う
- 将来スマホでの体験を高める手段として、**PWA**（ホーム画面に追加してアプリのように開ける）と**ネイティブアプリ**（React Nativeなど）を**比較・検討する**。どちらにするか、いつ作るかは決めていない
- いずれの場合も、同じRails APIをそのまま使う。ネイティブアプリを作る場合は、モノレポに`mobile/`を追加する

---

## 3. 実行環境：Docker（ローカル完結）

### 3-1. 方針

- 開発・日常利用ともに **Docker内で完結**させる
- 第1段階ではクラウドへのデプロイは行わない。将来は同じコンテナ構成をRender／Fly.ioなどへ持っていける形にしておく
- 操作は **Makefile** 経由にする（`make setup`・`make up`・`make test`・`make lint`・`make openapi`・`make rbs`・`make console`・`make down`）
- データと写真をまとめて書き出し・復元する **`make backup` / `make restore`** を用意する（`02_requirements.md` §2）

### 3-2. ディレクトリ構成

```text
project-root/
├── Makefile
├── docker-compose.yml
├── backend/               # Rails API
│   ├── Dockerfile
│   ├── doc/openapi.yaml   # request specから自動生成したAPI仕様書（make openapi）
│   └── ...
├── frontend/              # Next.js
│   ├── Dockerfile
│   └── ...
└── docs/                  # 設計書（01〜06）
```

将来ネイティブアプリを作る場合は、`backend/`・`frontend/`と同じ並びに`mobile/`を追加する。

### 3-3. コンテナ構成

| サービス名 | 役割 | イメージ |
| --- | --- | --- |
| `db` | PostgreSQL本体 | `postgres:16` |
| `backend` | Rails API | ローカルDockerfileでビルド |
| `frontend` | Next.js | ローカルDockerfileでビルド |

- `db`のデータと写真は名前付きボリュームで永続化する
- `backend` ⇄ `db` はDockerネットワーク内の名前解決（`db`ホスト名）で接続する
- `frontend` ⇄ `backend` はブラウザから`backend`のポートを直接呼ぶ（CORSをRails側で許可）
- ポート：`frontend`は3000、`backend`は3001（同じポートにしない）

### 3-4. CI

- GitHub Actions。mainへのpushとPRで実行する
  - backend：`db:prepare` → RSpec（カバレッジの基準値チェック込み） → RuboCop → Brakeman・bundler-audit → RBSの生成 → Steepの型チェック
  - frontend：ESLint → `tsc --noEmit` → Vitest
- CIはDockerを使わずネイティブ実行。Makefileの`test-*`・`lint-*`と手で同期させる

---

## 4. 認証方針

- 第1段階：認証なし（自分用・ローカル完結のため）
- 将来段階：トークン認証を追加し、各リソースに所有者を付ける。Web（ブラウザ）とスマホアプリの両方から使える方式を、そのときに選ぶ

---

## 5. 決定事項まとめ

| 項目 | 決定 |
| --- | --- |
| 方針 | anime-manga-managerと揃える。第1段階で使わないものは入れない |
| 構成 | APIは1つ・DBは1つ・画面は複数。マイクロサービスにしない |
| リポジトリ | モノレポ（`backend/`・`frontend/`、将来`mobile/`） |
| バックエンド | Rails（APIモード）＋Steep/RBS＋Alba＋RSpec＋rspec-openapi＋SimpleCov |
| フロントエンド | Next.js（App Router）＋TypeScript＋Tailwind＋React Hook Form＋zod＋Vitest |
| データベース | PostgreSQL 16 |
| 実行環境 | Docker（docker-compose、ローカル完結）＋Makefile |
| 認証 | 第1段階なし |
| デプロイ | 第1段階では行わない |
| スマホ | 未確定（PWAとネイティブアプリを比較検討） |

---

*次の文書（`06_screens.md` 画面仕様）では、この技術構成の上でどんな画面を作るか、どの画面がどのAPIを呼ぶかを設計する。*
