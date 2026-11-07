# API設計書

> バックエンド（Rails API）が提供するエンドポイントを定義する文書。
> フロントエンドはここで定義したAPIを通じてデータをやり取りする。Webフロントと将来のスマホアプリで共用する。
> 関連文書：`01_vision.md` / `02_requirements.md` / `03_data_model.md`

---

## 0. 基本方針

- **RESTful** な設計。リソースごとにエンドポイントを用意する。パスは複数形・スネークケース
- 子リソースは**浅いネスト**（Railsの`shallow: true`）：作成と一覧は親の下（`/recipes/:recipe_id/cooking_logs`）、1件の操作は直下（`/cooking_logs/:id`）
- **計算はAPIで行う**：いまのレシピの解決、分量の換算、「変えたところ」の差分は、APIが計算済みの値を返す。画面側では計算しない（`03_data_model.md` §3）
- **材料・手順はバージョンと一緒に保存する**：材料1行ごとのAPIは作らず、バージョンの更新で材料・手順の配列をまとめて送る。レシピのフォームは「全部入力してから保存」なので、1回の保存で整合した状態にするため
- 第1段階は**認証なし**（自分用・ローカル完結）

### 共通の約束

- ベースパス：`/api/v1`
- 文字コード：UTF-8。日時はISO 8601（例：`2026-11-08T12:00:00+09:00`）、日付は`YYYY-MM-DD`
- エラー時：HTTPステータス＋`{ "error": { "message": "...", "details": {...} } }`
- 一覧はJSONの配列（第1段階はページネーションなし）
- リクエストボディ（`POST`／`PATCH`）：レスポンスと同じキーを持つフラットなJSON（`{ "recipe": { ... } }`のように包まない）
- `PATCH`は部分更新：送ったキーだけを更新する。任意項目は`null`を送ると空に戻せる。必須項目に`null`を送ると`422`
- 配列で送る項目（`ingredients`・`steps`・`completed_photo_ids`）は**送った配列で丸ごと置き換える**。送らなければ変えない
- 未知のキーは無視する。値の型が違うと`422`（黙って変換しない）
- 主なステータスコード：取得・更新`200`、作成`201`（作成したリソースを返す）、削除`204`、不正なクエリパラメータ・解析できない本文`400`、見つからない`404`、バリデーションエラー`422`（`details`にフィールド名→メッセージの配列）
- 実装から自動生成したAPI仕様書（OpenAPI）は`backend/doc/openapi.yaml`。設計意図・仕様の正はこの文書

---

## 1. エンドポイント一覧

### 1-1. レシピ（recipes）

| メソッド | パス | 説明 |
| --- | --- | --- |
| GET | `/api/v1/recipes` | レシピ一覧（絞り込み・並び替え対応） |
| GET | `/api/v1/recipes/:id` | レシピ1件（オリジナル・いまのレシピ・アレンジ履歴の概要つき） |
| POST | `/api/v1/recipes` | レシピを登録。**オリジナルも同時に作る** |
| PATCH | `/api/v1/recipes/:id` | 料理名・元のURL・点数・レビュー・いまのレシピ（`current_version_id`）を更新 |
| DELETE | `/api/v1/recipes/:id` | レシピを削除（バージョン・写真・作った記録・メニュー表と献立の該当行も消える） |
| POST | `/api/v1/recipes/:id/derivations` | 派生レシピを作る。いまのレシピの中身をコピーして、新しいレシピのオリジナルにする |

- `POST /recipes`：必須は`name`だけ。`ingredients`・`steps`・`quantity_basis`などオリジナルの中身も同じリクエストで送れる（送らなければ空のオリジナルができる）
- `GET /recipes/:id`の`usage`に、載っているメニュー表の数・献立の数を返す（削除前の確認表示に使う）

一覧の絞り込み・並び替えクエリ：

- `?q=keyword` … 料理名のキーワード検索（部分一致）
- `?rating=4` … 点数で絞る（指定以上）
- `?sort=updated_at&order=desc` … 並び替え。`sort`は`updated_at`（既定）／`created_at`／`name`／`rating`／`last_cooked_on`
- 値が不正なら`400`。未知のパラメータ名は無視する

### 1-2. バージョン（オリジナル・アレンジ）

| メソッド | パス | 説明 |
| --- | --- | --- |
| GET | `/api/v1/recipes/:recipe_id/versions` | アレンジ履歴（オリジナルを含め`created_at`順。各バージョンの「変えたところ」の差分つき） |
| GET | `/api/v1/versions/:id` | バージョン1件の中身（材料・手順・写真・「変えたところ」）。換算のクエリに対応 |
| PATCH | `/api/v1/versions/:id` | 中身を更新（材料・手順・写真の紐付けは配列で丸ごと置き換え） |
| DELETE | `/api/v1/versions/:id` | アレンジを削除。オリジナルは`422` |
| POST | `/api/v1/versions/:id/arrangements` | **このバージョンをもとにアレンジを作る**（中身をコピーし、写真の紐付けを引き継ぐ） |

- `POST /versions/:id/arrangements`：本文に`change_note`（理由）と、変更したい中身（`ingredients`など）を含められる。作ったアレンジがそのレシピの最新になる
- 「作った」記録からアレンジを作る場合は、`cooking_log_id`を送ると、その記録の「次はこうしたい」を`change_note`の初期値にする

**分量の換算**（`GET /versions/:id`のクエリ）：

- `?scale_target=3` … そのバージョンの分量の基準（人数・個数・型のサイズ）を目標の値に換算する（例：2人分 → 3人分）
- `?scale_ingredient_id=12&scale_target=450` … 指定した材料を基準に換算する（例：鶏もも肉300g → 450g）。基準の種類によらず使える
- 換算したときは、各材料の`amount`に換算後の値、`original_amount`に元の値、全体に`scale`（倍率と基準）を返す。`amount_text`（少々など）はそのまま
- 基準が未設定のバージョンに`scale_target`だけを送った場合、`scale_target`が0以下の場合は`400`

### 1-3. 写真（photos）

| メソッド | パス | 説明 |
| --- | --- | --- |
| POST | `/api/v1/recipes/:recipe_id/photos` | 写真をアップロード（multipart）。`id`と表示用URLを返す |
| DELETE | `/api/v1/photos/:id` | 写真を削除（紐付けも外れる） |

- 写真をバージョンに付けるときは、アップロードで得た`id`を`PATCH /versions/:id`の`completed_photo_ids`（完成写真、最大2枚）や`steps[].photo_ids`（手順写真）に入れる
- どこからも紐付けられなくなった写真は、APIが削除する

### 1-4. 「作った」記録（cooking_logs）

| メソッド | パス | 説明 |
| --- | --- | --- |
| GET | `/api/v1/recipes/:recipe_id/cooking_logs` | そのレシピの作った記録（新しい順） |
| POST | `/api/v1/recipes/:recipe_id/cooking_logs` | 作った記録を追加。`recipe_version_id`を省くと、いまのレシピが入る。`cooked_on`を省くと今日 |
| PATCH | `/api/v1/cooking_logs/:id` | 日付・点数・メモを更新 |
| DELETE | `/api/v1/cooking_logs/:id` | 記録を削除 |

### 1-5. メニュー表（menus・menu_sections・menu_items）

| メソッド | パス | 説明 |
| --- | --- | --- |
| GET | `/api/v1/menus` | メニュー表の一覧 |
| GET | `/api/v1/menus/:id` | メニュー表1件（区切り・料理を並び順で。各料理はいまのレシピの名前・写真つき） |
| POST | `/api/v1/menus` | メニュー表を作成（名前・店名・テーマ） |
| PATCH | `/api/v1/menus/:id` | 名前・店名・テーマを更新 |
| DELETE | `/api/v1/menus/:id` | メニュー表を削除（区切り・料理も消える。レシピは消えない） |
| POST | `/api/v1/menus/:menu_id/sections` | 区切りを追加 |
| PATCH | `/api/v1/menu_sections/:id` | 区切りの名前を変更 |
| DELETE | `/api/v1/menu_sections/:id` | 区切りを削除（中の料理は「区切りなし」に移る） |
| POST | `/api/v1/menus/:menu_id/items` | 料理（レシピ）を追加。区切り・メニュー用説明文を指定できる |
| PATCH | `/api/v1/menu_items/:id` | メニュー用説明文・区切りを変更 |
| DELETE | `/api/v1/menu_items/:id` | 料理をメニュー表から外す |
| PUT | `/api/v1/menus/:id/order` | **区切りと料理の並び順をまとめて保存**（ドラッグで並べ替えた結果を1回で送る） |

- テーマは`restaurant`／`washoku`。定義外の値は`422`
- `PUT /menus/:id/order`の本文：`{ "sections": [{ "id": 1, "item_ids": [3, 5] }], "unsectioned_item_ids": [7] }`。そのメニュー表のすべての区切り・料理を含める（漏れや他のメニュー表のidがあれば`422`）

### 1-6. 献立（meal_plan_entries）

| メソッド | パス | 説明 |
| --- | --- | --- |
| GET | `/api/v1/meal_plan_entries?from=2026-11-09&to=2026-11-15` | 期間内の献立（日付・並び順。`from`・`to`は必須、最大62日） |
| POST | `/api/v1/meal_plan_entries` | 日付に料理を追加 |
| PATCH | `/api/v1/meal_plan_entries/:id` | 日付・並び順を変更 |
| DELETE | `/api/v1/meal_plan_entries/:id` | 献立から外す |

---

## 2. レスポンス例

### レシピ1件（`GET /api/v1/recipes/:id`）

```json
{
  "id": 1,
  "name": "鶏の照り焼き",
  "source_url": "https://www.youtube.com/watch?v=xxxx",
  "rating": 4,
  "review": "甘辛で家族にも好評",
  "derived_from": null,
  "current_version_id": null,
  "last_cooked_on": "2026-11-07",
  "cooked_count": 6,
  "usage": { "menus_count": 2, "meal_plan_entries_count": 1 },
  "original": { "id": 10, "label": "オリジナル", "...": "（バージョン1件と同じ形）" },
  "current": { "id": 13, "label": "アレンジ3", "...": "（バージョン1件と同じ形）" },
  "arrangements_count": 3,
  "created_at": "2026-10-01T10:00:00+09:00",
  "updated_at": "2026-11-07T19:30:00+09:00"
}
```

- `current`は解決済みのいまのレシピ（`current_version_id`が`null`なら最新のバージョン）。画面はこれをそのまま表示する
- `label`はAPIが付ける表示名（`name`が空なら「オリジナル」「アレンジ1」…）

### バージョン1件（`GET /api/v1/versions/:id?scale_target=3`）

```json
{
  "id": 13,
  "recipe_id": 1,
  "label": "アレンジ3",
  "is_original": false,
  "based_on_id": 12,
  "quantity_basis": "servings",
  "basis_value": 2,
  "basis_unit": null,
  "cooking_minutes": 25,
  "difficulty": 1,
  "scale": { "factor": 1.5, "basis": "servings", "from": 2, "to": 3 },
  "ingredients": [
    { "id": 101, "group_name": null, "name": "鶏もも肉", "amount": 450, "original_amount": 300, "amount_text": null, "unit": "g", "is_basis": false },
    { "id": 102, "group_name": "A", "name": "醤油", "amount": 3, "original_amount": 2, "amount_text": null, "unit": "大さじ", "is_basis": false },
    { "id": 103, "group_name": null, "name": "塩", "amount": null, "original_amount": null, "amount_text": "少々", "unit": null, "is_basis": false }
  ],
  "steps": [
    { "id": 201, "position": 1, "description": "鶏肉の皮目をフォークで刺す", "photos": [] }
  ],
  "completed_photos": [ { "id": 31, "url": "http://localhost:3001/rails/active_storage/..." } ],
  "changes": {
    "note": "甘すぎたので砂糖を減らし、生姜で香りを足した",
    "ingredients": [
      { "kind": "changed", "name": "砂糖", "from": "大さじ2", "to": "大さじ1" },
      { "kind": "added", "name": "生姜", "to": "1かけ" }
    ]
  }
}
```

- `changes`は「変えたところ」。`note`はユーザーが書いた理由、`ingredients`は`based_on_id`のバージョンと比べてAPIが計算した差分（`kind`は`added`／`removed`／`changed`）。オリジナルでは`null`
- 換算のクエリがなければ`scale`は`null`、`original_amount`は`amount`と同じ値

---

## 3. 将来拡張のためのメモ

- **認証**（公開版）：トークン認証を追加し、各リソースに所有者を付ける。パスは変えない
- **企業モード**：組織・店舗のエンドポイント（`/organizations`・`/stores`）を足し、メニュー表に`store_id`・料理に`price`を加える（`03_data_model.md` §6）
- **画像・PDFの書き出し**：メニュー表の書き出しは、画面側で作るかAPIで作るかをそのときに決める
- **ジャンル**：`/genres`と、レシピの`genre_ids`（配列で丸ごと置き換え）を足す

---

*次の文書（`06_screens.md`）では、どの画面がどのAPIを呼ぶかを設計する。*
