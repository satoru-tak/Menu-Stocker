# データベース設計

## 1. ER図

```
┌─────────────────┐
│     users       │
├─────────────────┤
│ id              │PK
│ email           │
│ encrypted_pwd   │
│ username        │
│ bio             │
│ created_at      │
│ updated_at      │
└────────┬────────┘
         │ 1
         │
         │ N
┌────────┴────────┐
│    recipes      │
├─────────────────┤
│ id              │PK
│ user_id         │FK
│ name            │
│ description     │
│ cooking_time    │
│ difficulty      │
│ serving_size    │
│ is_favorite     │
│ created_at      │
│ updated_at      │
└────┬────────────┘
     │ 1          │ 1
     │ N          │ N
┌────┴────────┐ ┌─┴───────────┐
│ingredients  │ │    steps    │
├─────────────┤ ├─────────────┤
│ id          │ │ id          │PK
│ recipe_id   │FK│ recipe_id   │FK
│ name        │ │ position    │
│ quantity    │ │ description │
│ unit        │ │ created_at  │
│ optional    │ │ updated_at  │
│ position    │ └─────────────┘
│ created_at  │
│ updated_at  │
└─────────────┘

┌─────────────────┐
│     menus       │
├─────────────────┤
│ id              │PK
│ user_id         │FK
│ name            │
│ description     │
│ theme           │
│ created_at      │
│ updated_at      │
└────────┬────────┘
         │ 1
         │
         │ N
┌────────┴────────┐
│  menu_items     │
├─────────────────┤
│ id              │PK
│ menu_id         │FK
│ recipe_id       │FK
│ section         │
│ position        │
│ created_at      │
│ updated_at      │
└─────────────────┘
```

## 2. テーブル定義

### users テーブル
ユーザー情報を管理

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|----------|------|
| id | bigint | NOT NULL | auto | 主キー |
| email | string | NOT NULL | - | メールアドレス（ユニーク） |
| encrypted_password | string | NOT NULL | - | 暗号化されたパスワード |
| reset_password_token | string | NULL | - | パスワードリセットトークン |
| reset_password_sent_at | datetime | NULL | - | パスワードリセット送信日時 |
| remember_created_at | datetime | NULL | - | ログイン記憶日時 |
| username | string | NULL | - | ユーザー名 |
| bio | text | NULL | - | 自己紹介 |
| created_at | datetime | NOT NULL | - | 作成日時 |
| updated_at | datetime | NOT NULL | - | 更新日時 |

**インデックス**
- email (ユニーク)
- reset_password_token (ユニーク)

### recipes テーブル
レシピ情報を管理

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|----------|------|
| id | bigint | NOT NULL | auto | 主キー |
| user_id | bigint | NOT NULL | - | ユーザーID（外部キー） |
| name | string | NOT NULL | - | レシピ名 |
| description | text | NULL | - | 説明 |
| cooking_time | integer | NULL | - | 調理時間（分） |
| difficulty | integer | NULL | 1 | 難易度（1:簡単, 2:普通, 3:難しい） |
| serving_size | integer | NULL | 2 | 何人分 |
| is_favorite | boolean | NULL | false | お気に入りフラグ |
| created_at | datetime | NOT NULL | - | 作成日時 |
| updated_at | datetime | NOT NULL | - | 更新日時 |

**インデックス**
- user_id
- name
- is_favorite

**外部キー制約**
- user_id → users.id (ON DELETE CASCADE)

### ingredients テーブル
材料情報を管理

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|----------|------|
| id | bigint | NOT NULL | auto | 主キー |
| recipe_id | bigint | NOT NULL | - | レシピID（外部キー） |
| name | string | NOT NULL | - | 材料名 |
| quantity | string | NULL | - | 分量 |
| unit | string | NULL | - | 単位 |
| optional | boolean | NULL | false | 任意の材料フラグ |
| position | integer | NULL | - | 表示順序 |
| created_at | datetime | NOT NULL | - | 作成日時 |
| updated_at | datetime | NOT NULL | - | 更新日時 |

**インデックス**
- recipe_id
- position

**外部キー制約**
- recipe_id → recipes.id (ON DELETE CASCADE)

### steps テーブル
調理手順を管理

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|----------|------|
| id | bigint | NOT NULL | auto | 主キー |
| recipe_id | bigint | NOT NULL | - | レシピID（外部キー） |
| position | integer | NOT NULL | - | 手順番号 |
| description | text | NOT NULL | - | 手順の説明 |
| created_at | datetime | NOT NULL | - | 作成日時 |
| updated_at | datetime | NOT NULL | - | 更新日時 |

**インデックス**
- recipe_id, position (複合ユニーク)

**外部キー制約**
- recipe_id → recipes.id (ON DELETE CASCADE)

### menus テーブル
メニュー情報を管理

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|----------|------|
| id | bigint | NOT NULL | auto | 主キー |
| user_id | bigint | NOT NULL | - | ユーザーID（外部キー） |
| name | string | NOT NULL | - | メニュー名 |
| description | text | NULL | - | 説明 |
| theme | string | NULL | 'default' | テーマ |
| created_at | datetime | NOT NULL | - | 作成日時 |
| updated_at | datetime | NOT NULL | - | 更新日時 |

**インデックス**
- user_id
- name

**外部キー制約**
- user_id → users.id (ON DELETE CASCADE)

### menu_items テーブル
メニューとレシピの関連を管理

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|----------|------|
| id | bigint | NOT NULL | auto | 主キー |
| menu_id | bigint | NOT NULL | - | メニューID（外部キー） |
| recipe_id | bigint | NOT NULL | - | レシピID（外部キー） |
| section | string | NULL | - | セクション名（前菜、メイン等） |
| position | integer | NOT NULL | - | 表示順序 |
| created_at | datetime | NOT NULL | - | 作成日時 |
| updated_at | datetime | NOT NULL | - | 更新日時 |

**インデックス**
- menu_id, position (複合)
- recipe_id

**外部キー制約**
- menu_id → menus.id (ON DELETE CASCADE)
- recipe_id → recipes.id (ON DELETE RESTRICT)

### active_storage_blobs テーブル
（Active Storage により自動生成）
画像ファイルのメタデータを管理

### active_storage_attachments テーブル
（Active Storage により自動生成）
画像とレコードの関連を管理

## 3. マイグレーション戦略

### 初期マイグレーション順序

1. `users` テーブル作成（Devise による）
2. `recipes` テーブル作成
3. `ingredients` テーブル作成
4. `steps` テーブル作成
5. `menus` テーブル作成
6. `menu_items` テーブル作成
7. Active Storage テーブル作成

### インデックス追加

パフォーマンス改善のため、以下のインデックスを追加：

```ruby
# 検索頻度の高いカラムにインデックス
add_index :recipes, :user_id
add_index :recipes, :name
add_index :recipes, :is_favorite
add_index :ingredients, :recipe_id
add_index :steps, [:recipe_id, :position], unique: true
add_index :menus, :user_id
add_index :menu_items, [:menu_id, :position]
```

## 4. データ整合性

### カスケード削除

- ユーザー削除時 → 関連するレシピ、メニューも削除
- レシピ削除時 → 関連する材料、手順も削除
- メニュー削除時 → 関連するメニューアイテムも削除

### 制約

- `menu_items.recipe_id` は RESTRICT（メニューに使用中のレシピは削除不可）

## 5. 将来の拡張

### カテゴリ・タグ機能

```
┌─────────────────┐
│   categories    │
├─────────────────┤
│ id              │PK
│ name            │
│ created_at      │
│ updated_at      │
└─────────────────┘

┌─────────────────┐
│      tags       │
├─────────────────┤
│ id              │PK
│ name            │
│ created_at      │
│ updated_at      │
└─────────────────┘

┌─────────────────┐
│  recipe_tags    │
├─────────────────┤
│ id              │PK
│ recipe_id       │FK
│ tag_id          │FK
│ created_at      │
│ updated_at      │
└─────────────────┘
```

### 献立カレンダー機能

```
┌─────────────────┐
│meal_plans       │
├─────────────────┤
│ id              │PK
│ user_id         │FK
│ recipe_id       │FK
│ meal_type       │
│ scheduled_date  │
│ created_at      │
│ updated_at      │
└─────────────────┘
```

## 6. バックアップ・復旧

### バックアップ戦略
- PostgreSQL の pg_dump による定期バックアップ
- 画像ファイルのバックアップ（Active Storage）

### 復旧手順
1. データベースの復元
2. 画像ファイルの復元
3. 整合性チェック

---

**更新日**: 2025-12-21
**バージョン**: 1.0
