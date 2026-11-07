# データ設計書

> レシピ・バージョン・メニュー表をどんなデータ構造で持つかを定義する文書。このプロジェクトの心臓部。
> 関連文書：`01_vision.md` / `02_requirements.md`

---

## 0. 設計の基本方針

- 第1段階は**自分用・認証なし**。ユーザーのテーブルは持たない（将来の拡張は §6）。
- レシピは「箱」、中身（材料・分量・手順）は**バージョン**として持つ。**アレンジを作ると中身をコピー**し、写真だけは**コピーせず紐付けを引き継ぐ**（写真ファイルを重複させないため）。
- **いまのレシピの解決**（未指定なら最新のバージョン）と**分量の換算**は、APIの1か所に集約する。画面側では計算しない（`05_tech_stack.md` §1-2）。
- メニュー表のテーマ（レストラン・和食屋など）は**コードで定義**し、テーブルにしない。見た目の実装（テンプレート）とセットで増えるため。
- 将来の拡張（ログイン・企業モード・ジャンル）を妨げない、素直な構造にする。

### 技術前提

- Ruby on Rails（APIモード）＋PostgreSQL。命名はRailsの規約に従う（モデルは単数・パスカルケース、テーブルは複数・スネークケース）。
- **カラム名に`type`を使わない**（RailsのSTI＝単一テーブル継承に予約されているため）。種類を持つカラムは`〇〇_kind`などの名前のenumにする。
- テーブル・カラムには**DBコメントを必ず付ける**（`.claude/rules/backend/migrations.md`）。意味の定義はこの文書が正。
- 写真は**Active Storage**で保存する（第1段階はローカルのディスク、公開版はS3などに切り替え）。

---

## 1. テーブル一覧

| テーブル | モデル名 | 役割 |
| --- | --- | --- |
| `recipes` | `Recipe` | レシピ（1つの料理の箱）。点数・レビュー・いまのレシピ・派生元を持つ |
| `recipe_versions` | `RecipeVersion` | バージョン（オリジナル・アレンジ）。分量の基準・バージョンのメモを持つ |
| `ingredients` | `Ingredient` | バージョンごとの材料と分量 |
| `steps` | `Step` | バージョンごとの手順 |
| `photos` | `Photo` | 写真（レシピ単位の置き場）。実ファイルはActive Storage |
| `version_photos` | `VersionPhoto` | バージョンと完成写真の紐付け（1バージョンにつき最大2枚） |
| `step_photos` | `StepPhoto` | 手順と手順写真の紐付け |
| `cooking_logs` | `CookingLog` | 「作った」記録（日付・作ったバージョン・任意の点数とメモ） |
| `menus` | `Menu` | メニュー表（店名・テーマ） |
| `menu_sections` | `MenuSection` | メニュー表の区切り（前菜・メインなど） |
| `menu_items` | `MenuItem` | メニュー表に載せる料理（レシピ＋メニュー用説明文） |
| `meal_plan_entries` | `MealPlanEntry` | 献立（日付に料理を並べる） |

ジャンル（`genres`・`recipe_genres`）は第1段階の後半以降（§5）。

---

## 2. 各テーブルの定義

### 2-1. `recipes`（レシピ / モデル `Recipe`）

| カラム | 型 | 必須 | 説明 |
| --- | --- | --- | --- |
| `name` | string | ○ | 料理名。**唯一の必須入力** |
| `source_url` | string | | 元の情報（動画・サイトのURL） |
| `rating` | integer | | 点数（1〜5）。NULLは未評価 |
| `review` | text | | レビュー（レシピに1つ、上書きして育てる） |
| `current_version_id` | references | | いまのレシピとして選んだバージョン。NULLなら最新のバージョンを使う |
| `derived_from_id` | references（`recipes`） | | 派生元のレシピ。NULLは派生ではない |

- 削除すると、バージョン・写真・「作った」記録・メニュー表と献立の該当行も消える（`dependent: :destroy`）。メニュー表や献立に載っている場合は、削除の前に「○つのメニュー表に載っています」と確認を出す（画面側）。
- 派生元のレシピが削除されたら、派生レシピの`derived_from_id`はNULLにする（派生レシピ自体は残す）。

### 2-2. `recipe_versions`（バージョン / モデル `RecipeVersion`）

| カラム | 型 | 必須 | 説明 |
| --- | --- | --- | --- |
| `recipe_id` | references | ○ | どのレシピのバージョンか |
| `based_on_id` | references（`recipe_versions`） | | もとにしたバージョン。オリジナルはNULL。バージョンの系譜をたどるのに使う |
| `name` | string | | バージョンの名前（例：砂糖控えめ）。空なら「オリジナル」「アレンジ1」…と自動で表示する |
| `is_original` | boolean | ○ | オリジナルかどうか。オリジナルは削除できない（1レシピに1つ） |
| `quantity_basis` | string（enum） | | 分量の基準：`servings`（人数）/ `pieces`（個数）/ `pan_size`（型のサイズ）/ `ingredient`（材料）。NULLは未設定（換算しない） |
| `basis_value` | decimal | | 基準の数値（2人分なら2、20枚分なら20、18cmの型なら18）。`ingredient`の場合は使わない（§2-3の`is_basis`） |
| `basis_unit` | string | | 個数の数え方（枚・個など）。`pieces`の場合のみ |
| `cooking_minutes` | integer | | 調理時間（分） |
| `difficulty` | integer | | 難易度：1＝簡単 / 2＝ふつう / 3＝難しい。ユーザーが自分の感覚で付ける |
| `change_note` | text | | 変えたところの理由（例：甘すぎたので）。任意。材料・分量の差はAPIが前のバージョンと比べて自動で出すので保存しない。オリジナルでは使わない |

- **アレンジを作る**：もとのバージョンの`ingredients`・`steps`をコピーし、`version_photos`・`step_photos`の紐付けもコピーする（写真ファイルはコピーしない）。
- **アレンジを削除する**（アレンジ履歴から。めったに使わない）：削除したアレンジを`based_on_id`で指しているバージョンは、削除したアレンジの`based_on_id`に付け替える（系譜が途切れないように）。`current_version_id`がこのアレンジならNULLに戻す。「作った」記録の`recipe_version_id`はNULLになる。
- オリジナルは削除できない。
- **アレンジ履歴**：`created_at`の順に並べたもの。
- **最新のバージョン**：`created_at`が最も新しいバージョン。

### 2-3. `ingredients`（材料 / モデル `Ingredient`）

| カラム | 型 | 必須 | 説明 |
| --- | --- | --- | --- |
| `recipe_version_id` | references | ○ | どのバージョンの材料か |
| `position` | integer | ○ | 並び順 |
| `group_name` | string | | 材料のグループ名（例：A、B、タレ）。NULLはグループなし。同じグループの材料はまとめて表示する |
| `name` | string | ○ | 材料名（例：鶏もも肉） |
| `amount` | decimal | | 分量の数値（例：300）。換算の対象。NULLは数値でない分量 |
| `amount_text` | string | | 数値で表せない分量（例：少々、適量、ひとつまみ）。換算せずそのまま表示する |
| `unit` | string | | 単位（例：g、大さじ、個） |
| `is_basis` | boolean | ○ | 分量の基準にする材料か（`quantity_basis`が`ingredient`のときに1つだけtrue） |

- 換算の対象は`amount`だけ。`amount_text`はそのまま表示する。

### 2-4. `steps`（手順 / モデル `Step`）

| カラム | 型 | 必須 | 説明 |
| --- | --- | --- | --- |
| `recipe_version_id` | references | ○ | どのバージョンの手順か |
| `position` | integer | ○ | 並び順 |
| `description` | text | ○ | 手順の内容 |

### 2-5. `photos`・`version_photos`・`step_photos`（写真と紐付け）

写真ファイルは`photos`に1回だけ保存し、バージョンや手順からは**中間テーブルで紐付ける**。アレンジは紐付けをコピーして引き継ぎ、入れ替えたい写真だけ紐付けを差し替える。

**`photos`（写真 / モデル `Photo`）**

| カラム | 型 | 必須 | 説明 |
| --- | --- | --- | --- |
| `recipe_id` | references | ○ | どのレシピの写真か（レシピ単位の置き場） |
| （Active Storage） | `has_one_attached :image` | ○ | 実ファイル。アップロード時に表示用サイズへ縮小・圧縮する |

**`version_photos`（バージョン×完成写真 / モデル `VersionPhoto`）**

| カラム | 型 | 必須 | 説明 |
| --- | --- | --- | --- |
| `recipe_version_id` | references | ○ | バージョン |
| `photo_id` | references | ○ | 写真 |
| `position` | integer | ○ | 並び順。**1バージョンにつき最大2枚**（バリデーション） |

**`step_photos`（手順×手順写真 / モデル `StepPhoto`）**

| カラム | 型 | 必須 | 説明 |
| --- | --- | --- | --- |
| `step_id` | references | ○ | 手順 |
| `photo_id` | references | ○ | 写真 |
| `position` | integer | ○ | 並び順 |

- どのバージョン・手順からも紐付けられなくなった写真は、削除する（実ファイルも消す）。

### 2-6. `cooking_logs`（「作った」記録 / モデル `CookingLog`）

| カラム | 型 | 必須 | 説明 |
| --- | --- | --- | --- |
| `recipe_id` | references | ○ | どのレシピを作ったか |
| `recipe_version_id` | references | | 作ったバージョン（記録時に自動で入る）。バージョンが削除されたらNULL |
| `cooked_on` | date | ○ | 作った日 |
| `rating` | integer | | その回の点数（1〜5）。任意 |
| `memo` | text | | その回の振り返り（試作の記録）。任意 |

- 「最後に作った日」「作った回数」はこのテーブルから集計する（レシピ側に持たない）。

### 2-7. `menus`・`menu_sections`・`menu_items`（メニュー表）

**`menus`（メニュー表 / モデル `Menu`）**

| カラム | 型 | 必須 | 説明 |
| --- | --- | --- | --- |
| `name` | string | ○ | メニュー表の名前（例：週末の居酒屋メニュー） |
| `shop_name` | string | | 店名（例：和食屋 ○○） |
| `theme` | string（enum） | ○ | テーマ：`restaurant`（レストラン）/ `washoku`（和食屋）。第1段階はこの2つ |

**`menu_sections`（区切り / モデル `MenuSection`）**

| カラム | 型 | 必須 | 説明 |
| --- | --- | --- | --- |
| `menu_id` | references | ○ | どのメニュー表の区切りか |
| `name` | string | ○ | 区切りの名前（例：前菜、おつまみ、〆） |
| `position` | integer | ○ | 並び順 |

**`menu_items`（メニューの料理 / モデル `MenuItem`）**

| カラム | 型 | 必須 | 説明 |
| --- | --- | --- | --- |
| `menu_id` | references | ○ | どのメニュー表か |
| `menu_section_id` | references | | どの区切りか。NULLは区切りなし |
| `recipe_id` | references | ○ | 載せるレシピ。表示するのはいまのレシピ |
| `position` | integer | ○ | 並び順（区切りの中での順） |
| `description` | text | | メニュー用の説明文（例：じっくり煮込んだ自慢の一品） |

- 区切りを削除したら、中の料理は「区切りなし」に移す（`menu_section_id`をNULLにする）。

### 2-8. `meal_plan_entries`（献立 / モデル `MealPlanEntry`）

| カラム | 型 | 必須 | 説明 |
| --- | --- | --- | --- |
| `planned_on` | date | ○ | 作る予定の日 |
| `recipe_id` | references | ○ | 作る料理 |
| `position` | integer | ○ | その日の中での並び順 |

- 朝・昼・夜などの区切りは持たない（`02_requirements.md` §6 の未決事項）。

---

## 3. 重要な設計判断

### 3-1. いまのレシピの解決は1か所に集約する

一覧・メニュー表・献立で表示するバージョンは、「`current_version_id`があればそのバージョン、なければ最新のバージョン」。この解決は**モデル（`Recipe#display_version`）の1か所**に置き、APIは解決済みのバージョンを返す。画面やほかの場所で同じ判定を書かない。

### 3-2. 分量の換算はAPIで行い、元のデータは書き換えない

換算は表示のための計算で、保存している分量は変えない。倍率は基準ごとに次の通り。

| 基準 | 倍率 |
| --- | --- |
| 人数・個数・材料 | 目標の値 ÷ 基準の値 |
| 型のサイズ | （目標の直径 ÷ 基準の直径）²（面積の比） |

- `amount`に倍率をかけ、`amount_text`はそのまま返す。
- 計算はサービス層の1か所（例：`RecipeVersions::Scale`）に置く。

### 3-3. 「変えたところ」の差分は保存せず、APIで出す

アレンジの材料・分量の差（例：砂糖 大さじ2 → 大さじ1、生姜を追加）は、`based_on_id`の指すバージョンと比べてAPIが計算して返す。保存するのはユーザーが書く理由（`change_note`）だけにし、差分と実データがずれないようにする。計算はサービス層の1か所（例：`RecipeVersions::Diff`）に置く。

### 3-4. 中身はコピー、写真は紐付け

材料・手順はバージョンごとに変わる前提なのでコピーして持つ。写真はバージョンの間で共通なことが多く、容量も大きいので、ファイルは1回だけ保存して紐付けを引き継ぐ。

---

## 4. 関係のまとめ

```text
recipes 1 ──< recipe_versions 1 ──< ingredients
   │              │            └──< steps 1 ──< step_photos >── photos
   │              └──< version_photos >── photos
   ├──< photos
   ├──< cooking_logs >── recipe_versions（作ったバージョン・任意）
   ├── current_version ── recipe_versions（任意）
   └── derived_from ── recipes（派生元・任意）

menus 1 ──< menu_sections 1 ──< menu_items >── recipes
   └──< menu_items（区切りなし）

meal_plan_entries >── recipes
```

---

## 5. 第1段階の後半以降に足すもの

### 5-1. ジャンル

- `genres`（ジャンル）と`recipe_genres`（レシピ×ジャンル、多対多）。1つのレシピに複数のジャンルを付けられる
- 階層（例：和風 > 煮物）を持つか、初期値を用意するかは未定（`02_requirements.md` §6）

---

## 6. 将来の拡張（公開版・企業モード）

第1段階ではテーブルを作らない。ここに書いた形へ素直に拡張できるよう、第1段階の設計でこれを妨げないこと。

### 6-1. ログイン（公開版）

- `users`を追加し、各リソース（`recipes`・`menus`・`meal_plan_entries`）に所有者を付ける

### 6-2. 企業モード（組織・店舗）

```text
users ──< memberships >── organizations 1 ──< stores 1 ──< menus
 (人)     (役割：オーナー／スタッフ)   (企業)        (店舗・ロゴ)
```

- ログインする人（`users`）とデータを持つ側（`organizations`）を分ける。1つの組織に複数の人が所属でき、店長とスタッフが同じ店のメニューを編集できる
- 店舗は組織に対して1対多（多店舗を管理できる）。ロゴ・店名は店舗が持ち、メニュー表から参照する
- `menus.store_id`は任意の外部キー。NULLは個人のメニュー表
- 個人か企業かの区別は`account_kind`などのenumで持つ（`type`は使わない）
- メニューの価格は`menu_items.price`として追加する（レシピには持たせない。同じ料理でも店やメニューで値段が変わるため）

---

*次の文書（`04_api_design.md`）では、このデータ構造をどんなAPIで読み書きするかを設計する。*
