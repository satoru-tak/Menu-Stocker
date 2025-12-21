# API 設計書

## 1. 基本情報

### ベースURL
- 開発環境: `http://localhost:3000/api/v1`
- 本番環境: `https://api.menu-stocker.com/api/v1`

### 認証方式
- JWT (JSON Web Token) ベース
- ヘッダー: `Authorization: Bearer {token}`

### レスポンス形式
- Content-Type: `application/json`
- 文字コード: UTF-8

### ステータスコード

| コード | 説明 |
|-------|------|
| 200 | OK - 成功 |
| 201 | Created - リソース作成成功 |
| 204 | No Content - 削除成功 |
| 400 | Bad Request - リクエストエラー |
| 401 | Unauthorized - 認証エラー |
| 403 | Forbidden - 権限エラー |
| 404 | Not Found - リソースが見つからない |
| 422 | Unprocessable Entity - バリデーションエラー |
| 500 | Internal Server Error - サーバーエラー |

## 2. 認証 API

### 2.1 ユーザー登録

**エンドポイント**: `POST /users/sign_up`

**リクエスト**
```json
{
  "user": {
    "email": "user@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "username": "山田太郎"
  }
}
```

**レスポンス** (201 Created)
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "username": "山田太郎",
    "created_at": "2025-12-21T10:00:00Z"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### 2.2 ログイン

**エンドポイント**: `POST /users/sign_in`

**リクエスト**
```json
{
  "user": {
    "email": "user@example.com",
    "password": "password123"
  }
}
```

**レスポンス** (200 OK)
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "username": "山田太郎"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### 2.3 ログアウト

**エンドポイント**: `DELETE /users/sign_out`

**ヘッダー**
```
Authorization: Bearer {token}
```

**レスポンス** (200 OK)
```json
{
  "status": "success",
  "message": "ログアウトしました"
}
```

### 2.4 現在のユーザー情報

**エンドポイント**: `GET /users/current`

**ヘッダー**
```
Authorization: Bearer {token}
```

**レスポンス** (200 OK)
```json
{
  "data": {
    "id": 1,
    "email": "user@example.com",
    "username": "山田太郎",
    "bio": "料理が好きです",
    "created_at": "2025-12-21T10:00:00Z"
  }
}
```

## 3. レシピ API

### 3.1 レシピ一覧取得

**エンドポイント**: `GET /recipes`

**クエリパラメータ**
- `page`: ページ番号（デフォルト: 1）
- `per_page`: 1ページあたりの件数（デフォルト: 20）
- `is_favorite`: お気に入りフィルタ（true/false）
- `q`: 検索キーワード

**レスポンス** (200 OK)
```json
{
  "data": [
    {
      "id": 1,
      "name": "カレーライス",
      "description": "スパイシーで美味しいカレー",
      "cooking_time": 60,
      "difficulty": 2,
      "serving_size": 4,
      "is_favorite": true,
      "image_url": "https://...",
      "created_at": "2025-12-21T10:00:00Z",
      "updated_at": "2025-12-21T10:00:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 100,
    "per_page": 20
  }
}
```

### 3.2 レシピ詳細取得

**エンドポイント**: `GET /recipes/:id`

**レスポンス** (200 OK)
```json
{
  "data": {
    "id": 1,
    "name": "カレーライス",
    "description": "スパイシーで美味しいカレー",
    "cooking_time": 60,
    "difficulty": 2,
    "serving_size": 4,
    "is_favorite": true,
    "image_url": "https://...",
    "ingredients": [
      {
        "id": 1,
        "name": "玉ねぎ",
        "quantity": "2",
        "unit": "個",
        "optional": false,
        "position": 1
      },
      {
        "id": 2,
        "name": "カレールー",
        "quantity": "1",
        "unit": "箱",
        "optional": false,
        "position": 2
      }
    ],
    "steps": [
      {
        "id": 1,
        "position": 1,
        "description": "玉ねぎをみじん切りにする"
      },
      {
        "id": 2,
        "position": 2,
        "description": "鍋に油を熱し、玉ねぎを炒める"
      }
    ],
    "created_at": "2025-12-21T10:00:00Z",
    "updated_at": "2025-12-21T10:00:00Z"
  }
}
```

### 3.3 レシピ作成

**エンドポイント**: `POST /recipes`

**リクエスト**
```json
{
  "recipe": {
    "name": "カレーライス",
    "description": "スパイシーで美味しいカレー",
    "cooking_time": 60,
    "difficulty": 2,
    "serving_size": 4,
    "ingredients_attributes": [
      {
        "name": "玉ねぎ",
        "quantity": "2",
        "unit": "個",
        "optional": false,
        "position": 1
      }
    ],
    "steps_attributes": [
      {
        "position": 1,
        "description": "玉ねぎをみじん切りにする"
      }
    ]
  }
}
```

**レスポンス** (201 Created)
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "name": "カレーライス",
    ...
  }
}
```

### 3.4 レシピ更新

**エンドポイント**: `PUT /recipes/:id` または `PATCH /recipes/:id`

**リクエスト**
```json
{
  "recipe": {
    "name": "特製カレーライス",
    "cooking_time": 90
  }
}
```

**レスポンス** (200 OK)
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "name": "特製カレーライス",
    ...
  }
}
```

### 3.5 レシピ削除

**エンドポイント**: `DELETE /recipes/:id`

**レスポンス** (204 No Content)

### 3.6 レシピ画像アップロード

**エンドポイント**: `POST /recipes/:id/image`

**リクエスト** (multipart/form-data)
```
image: (ファイル)
```

**レスポンス** (200 OK)
```json
{
  "status": "success",
  "data": {
    "image_url": "https://..."
  }
}
```

## 4. メニュー API

### 4.1 メニュー一覧取得

**エンドポイント**: `GET /menus`

**レスポンス** (200 OK)
```json
{
  "data": [
    {
      "id": 1,
      "name": "今週の献立",
      "description": "家族のための1週間メニュー",
      "theme": "default",
      "recipes_count": 5,
      "created_at": "2025-12-21T10:00:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 2,
    "total_count": 15
  }
}
```

### 4.2 メニュー詳細取得

**エンドポイント**: `GET /menus/:id`

**レスポンス** (200 OK)
```json
{
  "data": {
    "id": 1,
    "name": "今週の献立",
    "description": "家族のための1週間メニュー",
    "theme": "default",
    "menu_items": [
      {
        "id": 1,
        "section": "前菜",
        "position": 1,
        "recipe": {
          "id": 1,
          "name": "サラダ",
          "image_url": "https://...",
          "cooking_time": 10
        }
      },
      {
        "id": 2,
        "section": "メイン",
        "position": 2,
        "recipe": {
          "id": 2,
          "name": "ステーキ",
          "image_url": "https://...",
          "cooking_time": 30
        }
      }
    ],
    "created_at": "2025-12-21T10:00:00Z"
  }
}
```

### 4.3 メニュー作成

**エンドポイント**: `POST /menus`

**リクエスト**
```json
{
  "menu": {
    "name": "今週の献立",
    "description": "家族のための1週間メニュー",
    "theme": "default",
    "menu_items_attributes": [
      {
        "recipe_id": 1,
        "section": "前菜",
        "position": 1
      },
      {
        "recipe_id": 2,
        "section": "メイン",
        "position": 2
      }
    ]
  }
}
```

**レスポンス** (201 Created)
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "name": "今週の献立",
    ...
  }
}
```

### 4.4 メニュー更新

**エンドポイント**: `PUT /menus/:id`

**レスポンス** (200 OK)

### 4.5 メニュー削除

**エンドポイント**: `DELETE /menus/:id`

**レスポンス** (204 No Content)

### 4.6 メニューPDF出力

**エンドポイント**: `GET /menus/:id/export`

**クエリパラメータ**
- `format`: pdf (デフォルト)
- `theme`: デザインテーマ

**レスポンス** (200 OK)
- Content-Type: application/pdf
- PDFファイルをバイナリで返却

## 5. エラーレスポンス

### バリデーションエラー (422)

```json
{
  "status": "error",
  "errors": {
    "name": ["を入力してください"],
    "email": ["は既に使用されています"]
  }
}
```

### 認証エラー (401)

```json
{
  "status": "error",
  "message": "ログインが必要です"
}
```

### 権限エラー (403)

```json
{
  "status": "error",
  "message": "このリソースへのアクセス権限がありません"
}
```

### リソースが見つからない (404)

```json
{
  "status": "error",
  "message": "レシピが見つかりません"
}
```

## 6. レート制限

- 認証済みユーザー: 1000リクエスト/時間
- 未認証ユーザー: 100リクエスト/時間

レート制限に達した場合:
```json
{
  "status": "error",
  "message": "リクエスト制限に達しました。しばらくしてから再度お試しください",
  "retry_after": 3600
}
```

## 7. ページネーション

すべてのリスト取得APIはページネーションをサポート:

**クエリパラメータ**
- `page`: ページ番号（1から開始）
- `per_page`: 1ページあたりの件数（最大100）

**レスポンスメタ情報**
```json
{
  "meta": {
    "current_page": 1,
    "total_pages": 10,
    "total_count": 200,
    "per_page": 20
  }
}
```

## 8. バージョニング

- 現在のバージョン: v1
- URL パス: `/api/v1/*`
- 将来のバージョンアップ時は `/api/v2/*` を追加

---

**更新日**: 2025-12-21
**バージョン**: 1.0
