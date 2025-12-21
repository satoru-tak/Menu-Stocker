# Rails API 実装規約

## 1. アーキテクチャ概要

Menu Stocker Backend は、クリーンアーキテクチャの考え方を取り入れたレイヤードアーキテクチャを採用しています。

```
Request
   ↓
┌─────────────────────────────────────┐
│  Controller (API層)                  │  ← ルーティング、認証、レスポンス返却
└─────────────────────────────────────┘
   ↓
┌─────────────────────────────────────┐
│  Form Object                         │  ← 入力バリデーション、パラメータ整形
└─────────────────────────────────────┘
   ↓
┌─────────────────────────────────────┐
│  Service                             │  ← ビジネスロジック、トランザクション
└─────────────────────────────────────┘
   ↓
┌─────────────────────────────────────┐
│  Model                               │  ← 永続化、ドメインルール、リレーション
└─────────────────────────────────────┘
   ↓
┌─────────────────────────────────────┐
│  Resource (Alba)                     │  ← JSON整形、レスポンス構造定義
└─────────────────────────────────────┘
   ↓
Response
```

## 2. ディレクトリ構成

```
app/
├── controllers/
│   ├── application_controller.rb
│   ├── concerns/
│   │   ├── error_handler.rb           # エラーハンドリング
│   │   └── pagination.rb              # ページネーション
│   └── api/
│       └── v1/
│           ├── base_controller.rb     # API v1 基底クラス
│           ├── auth_controller.rb     # 認証
│           ├── recipes_controller.rb
│           ├── menus_controller.rb
│           └── users_controller.rb
│
├── forms/
│   ├── application_form.rb            # Form 基底クラス
│   ├── recipes/
│   │   ├── create_form.rb
│   │   └── update_form.rb
│   ├── menus/
│   │   └── create_form.rb
│   └── users/
│       ├── registration_form.rb
│       └── update_form.rb
│
├── services/
│   ├── application_service.rb         # Service 基底クラス
│   ├── recipes/
│   │   ├── create_service.rb
│   │   ├── update_service.rb
│   │   └── destroy_service.rb
│   ├── menus/
│   │   ├── create_service.rb
│   │   └── export_pdf_service.rb
│   └── auth/
│       └── authenticate_service.rb
│
├── resources/
│   ├── application_resource.rb        # Alba 基底クラス
│   ├── recipe_resource.rb
│   ├── recipe_detail_resource.rb      # 詳細用（関連含む）
│   ├── menu_resource.rb
│   ├── ingredient_resource.rb
│   └── user_resource.rb
│
├── queries/
│   ├── application_query.rb           # Query 基底クラス
│   ├── recipes_query.rb
│   └── menus_query.rb
│
├── policies/
│   ├── application_policy.rb          # Pundit 基底クラス
│   ├── recipe_policy.rb
│   └── menu_policy.rb
│
└── models/
    ├── application_record.rb
    ├── user.rb
    ├── recipe.rb
    ├── ingredient.rb
    ├── step.rb
    ├── menu.rb
    └── menu_item.rb
```

## 3. 各層の責務と実装ルール

### 3.1 Controller（API層）

**責務**
- HTTPリクエストの受け取り
- 認証・認可の確認
- Form/Service の呼び出し
- HTTPレスポンスの返却

**ルール**
- ビジネスロジックを書かない
- 1アクション = 1つのService呼び出しが理想
- Strong Parameters は Form に委譲

```ruby
# app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < ApplicationController
      include ErrorHandler
      include Pagination

      before_action :authenticate_user!

      private

      def current_user
        @current_user ||= User.find(decoded_token[:user_id])
      end

      def render_success(data, status: :ok, meta: {})
        render json: { data: data, meta: meta }, status: status
      end

      def render_created(data)
        render json: { data: data }, status: :created
      end

      def render_no_content
        head :no_content
      end
    end
  end
end
```

```ruby
# app/controllers/api/v1/recipes_controller.rb
module Api
  module V1
    class RecipesController < BaseController
      before_action :set_recipe, only: [:show, :update, :destroy]

      # GET /api/v1/recipes
      def index
        query = RecipesQuery.new(current_user.recipes)
        recipes = query.search(params[:q])
                       .filter_by_favorite(params[:is_favorite])
                       .order_by_recent
                       .page(params[:page])

        render_success(
          RecipeResource.new(recipes).serialize,
          meta: pagination_meta(recipes)
        )
      end

      # GET /api/v1/recipes/:id
      def show
        authorize @recipe
        render_success(RecipeDetailResource.new(@recipe).serialize)
      end

      # POST /api/v1/recipes
      def create
        form = Recipes::CreateForm.new(recipe_params)

        if (attrs = form.execute)
          result = Recipes::CreateService.invoke(attrs: attrs, user: current_user)
          authorize result.recipe
          render_created(RecipeDetailResource.new(result.recipe).serialize)
        else
          render_validation_errors(form.errors)
        end
      end

      # PATCH /api/v1/recipes/:id
      def update
        authorize @recipe
        form = Recipes::UpdateForm.new(recipe_params)

        if (attrs = form.execute)
          result = Recipes::UpdateService.invoke(recipe: @recipe, attrs: attrs)
          render_success(RecipeDetailResource.new(result.recipe).serialize)
        else
          render_validation_errors(form.errors)
        end
      end

      # DELETE /api/v1/recipes/:id
      def destroy
        authorize @recipe
        Recipes::DestroyService.invoke(recipe: @recipe)
        render_no_content
      end

      private

      def set_recipe
        @recipe = current_user.recipes.find(params[:id])
      end

      def recipe_params
        params.require(:recipe).permit(
          :name, :description, :cooking_time, :difficulty, :serving_size,
          ingredients_attributes: [:id, :name, :quantity, :unit, :optional, :position, :_destroy],
          steps_attributes: [:id, :position, :description, :_destroy]
        )
      end
    end
  end
end
```

### 3.2 Form Object

**責務**
- 入力値のバリデーション
- パラメータの型変換・整形
- 複数モデルにまたがるバリデーション

**ルール**
- ActiveModel::Model を include
- バリデーションロジックのみ記述
- 永続化処理は書かない

```ruby
# app/forms/application_form.rb
class ApplicationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  # バリデーションを実行し、成功時は属性を返却
  # @return [Hash, nil] 成功時は属性ハッシュ、失敗時は nil
  # @example
  #   form = Recipes::CreateForm.new(params)
  #   if (attrs = form.execute)
  #     Recipes::CreateService.invoke(attrs: attrs, user: current_user)
  #   else
  #     render_validation_errors(form.errors)
  #   end
  def execute
    return nil unless valid?

    to_h
  end

  # エラーメッセージをハッシュ形式で返却
  def error_messages
    errors.messages.transform_values(&:first)
  end

  # フォームの属性をハッシュで返却
  def to_h
    attributes.symbolize_keys
  end
end
```

```ruby
# app/forms/recipes/create_form.rb
module Recipes
  class CreateForm < ApplicationForm
    attribute :name, :string
    attribute :description, :string
    attribute :cooking_time, :integer
    attribute :difficulty, :integer, default: 1
    attribute :serving_size, :integer, default: 2
    attribute :ingredients_attributes, default: []
    attribute :steps_attributes, default: []

    validates :name, presence: true, length: { maximum: 100 }
    validates :cooking_time, numericality: { greater_than: 0 }, allow_nil: true
    validates :difficulty, inclusion: { in: 1..3 }
    validates :serving_size, numericality: { greater_than: 0 }

    validate :validate_ingredients
    validate :validate_steps

    private

    def validate_ingredients
      return if ingredients_attributes.blank?

      ingredients_attributes.each_with_index do |ingredient, index|
        if ingredient[:name].blank?
          errors.add(:ingredients, "#{index + 1}番目の材料名を入力してください")
        end
      end
    end

    def validate_steps
      return if steps_attributes.blank?

      steps_attributes.each_with_index do |step, index|
        if step[:description].blank?
          errors.add(:steps, "#{index + 1}番目の手順を入力してください")
        end
      end
    end
  end
end
```

### 3.3 Service

**責務**
- ビジネスロジックの実行
- トランザクション管理
- 複数モデルの協調処理
- 外部サービスとの連携

**ルール**
- 1 Service = 1 ユースケース
- `invoke` クラスメソッドで実行（処理を「呼び出す」意図を明確に）
- 結果は Result オブジェクトで返却
- 例外は適切にハンドリング

```ruby
# app/services/application_service.rb
class ApplicationService
  # 結果オブジェクト
  Result = Struct.new(:success?, :data, :error, keyword_init: true) do
    def failure?
      !success?
    end

    # data から属性を取得するためのメソッド委譲
    def method_missing(method_name, *args, &block)
      if data.is_a?(Hash) && data.key?(method_name)
        data[method_name]
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      (data.is_a?(Hash) && data.key?(method_name)) || super
    end
  end

  # ビジネスロジックを実行
  # @example
  #   result = Recipes::CreateService.invoke(attrs: attrs, user: user)
  #   if result.success?
  #     render_created(RecipeResource.new(result.recipe).serialize)
  #   else
  #     render_error(result.error)
  #   end
  def self.invoke(...)
    new(...).invoke
  end

  # サブクラスで実装
  def invoke
    raise NotImplementedError, "#{self.class}#invoke を実装してください"
  end

  private

  def success(data = {})
    Result.new(success?: true, data: data)
  end

  def failure(error)
    Result.new(success?: false, error: error)
  end
end
```

```ruby
# app/services/recipes/create_service.rb
module Recipes
  class CreateService < ApplicationService
    def initialize(attrs:, user:)
      @attrs = attrs
      @user = user
    end

    def invoke
      recipe = nil

      ActiveRecord::Base.transaction do
        recipe = @user.recipes.create!(
          name: @attrs[:name],
          description: @attrs[:description],
          cooking_time: @attrs[:cooking_time],
          difficulty: @attrs[:difficulty],
          serving_size: @attrs[:serving_size]
        )

        create_ingredients(recipe)
        create_steps(recipe)
      end

      success(recipe: recipe)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.message)
    end

    private

    def create_ingredients(recipe)
      return if @attrs[:ingredients_attributes].blank?

      @attrs[:ingredients_attributes].each do |attrs|
        recipe.ingredients.create!(attrs.except(:_destroy))
      end
    end

    def create_steps(recipe)
      return if @attrs[:steps_attributes].blank?

      @attrs[:steps_attributes].each do |attrs|
        recipe.steps.create!(attrs.except(:_destroy))
      end
    end
  end
end
```

### 3.4 Resource（Alba）

**責務**
- JSONレスポンスの構造定義
- 属性の変換・フォーマット
- 関連データのネスト

**ルール**
- 1 Resource = 1 レスポンス形式
- 詳細用・一覧用で分ける場合あり
- 日時は ISO8601 形式で返却

```ruby
# app/resources/application_resource.rb
class ApplicationResource
  include Alba::Resource

  # 日時のデフォルトフォーマット
  transform_keys :lower_camel

  # 共通の日時フォーマット
  def self.timestamp(name)
    attribute name do |resource|
      resource.public_send(name)&.iso8601
    end
  end
end
```

```ruby
# app/resources/recipe_resource.rb
class RecipeResource < ApplicationResource
  attributes :id, :name, :description, :cooking_time,
             :difficulty, :serving_size, :is_favorite

  timestamp :created_at
  timestamp :updated_at

  attribute :image_url do |recipe|
    recipe.image.attached? ? Rails.application.routes.url_helpers.url_for(recipe.image) : nil
  end
end
```

```ruby
# app/resources/recipe_detail_resource.rb
class RecipeDetailResource < ApplicationResource
  attributes :id, :name, :description, :cooking_time,
             :difficulty, :serving_size, :is_favorite

  timestamp :created_at
  timestamp :updated_at

  attribute :image_url do |recipe|
    recipe.image.attached? ? Rails.application.routes.url_helpers.url_for(recipe.image) : nil
  end

  many :ingredients, resource: IngredientResource
  many :steps, resource: StepResource
end
```

```ruby
# app/resources/ingredient_resource.rb
class IngredientResource < ApplicationResource
  attributes :id, :name, :quantity, :unit, :optional, :position
end
```

### 3.5 Query Object

**責務**
- 複雑な検索条件のカプセル化
- スコープの組み合わせ
- ソート・フィルタリング

**ルール**
- ActiveRecord::Relation を返却
- メソッドチェーン可能に設計
- モデルに依存しすぎない

```ruby
# app/queries/application_query.rb
class ApplicationQuery
  attr_reader :relation

  def initialize(relation = default_relation)
    @relation = relation
  end

  private

  def default_relation
    raise NotImplementedError
  end
end
```

```ruby
# app/queries/recipes_query.rb
class RecipesQuery < ApplicationQuery
  def search(keyword)
    return self if keyword.blank?

    @relation = @relation.where(
      "name ILIKE :keyword OR description ILIKE :keyword",
      keyword: "%#{keyword}%"
    )
    self
  end

  def filter_by_favorite(is_favorite)
    return self if is_favorite.nil?

    @relation = @relation.where(is_favorite: is_favorite)
    self
  end

  def filter_by_difficulty(difficulty)
    return self if difficulty.blank?

    @relation = @relation.where(difficulty: difficulty)
    self
  end

  def order_by_recent
    @relation = @relation.order(created_at: :desc)
    self
  end

  def order_by_name
    @relation = @relation.order(:name)
    self
  end

  def page(page_number, per_page: 20)
    @relation = @relation.page(page_number).per(per_page)
    self
  end

  private

  def default_relation
    Recipe.all
  end
end
```

### 3.6 Policy（Pundit）

**責務**
- 認可ロジック（誰が何をできるか）
- リソースへのアクセス制御

**ルール**
- 1 Policy = 1 Model
- メソッド名は `アクション名?`
- true/false を返却

```ruby
# app/policies/application_policy.rb
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    true
  end

  def show?
    owner?
  end

  def create?
    true
  end

  def update?
    owner?
  end

  def destroy?
    owner?
  end

  private

  def owner?
    record.user_id == user.id
  end
end
```

```ruby
# app/policies/recipe_policy.rb
class RecipePolicy < ApplicationPolicy
  def show?
    owner? || record.public?
  end

  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end
end
```

## 4. 命名規則

### ファイル名

| 種類 | 命名規則 | 例 |
|------|---------|-----|
| Controller | 複数形_controller.rb | `recipes_controller.rb` |
| Form | 動詞_form.rb | `create_form.rb`, `update_form.rb` |
| Service | 動詞_service.rb | `create_service.rb`, `export_pdf_service.rb` |
| Resource | 単数形_resource.rb | `recipe_resource.rb` |
| Query | 複数形_query.rb | `recipes_query.rb` |
| Policy | 単数形_policy.rb | `recipe_policy.rb` |

### クラス名

| 種類 | 命名規則 | 例 |
|------|---------|-----|
| Controller | 複数形Controller | `RecipesController` |
| Form | 動詞Form | `Recipes::CreateForm` |
| Service | 動詞Service | `Recipes::CreateService` |
| Resource | 単数形Resource | `RecipeResource` |
| Query | 複数形Query | `RecipesQuery` |
| Policy | 単数形Policy | `RecipePolicy` |

### メソッド名

```ruby
# Form - execute でバリデーション＆属性取得
attrs = Recipes::CreateForm.new(params).execute  # => Hash or nil

# Service - invoke でビジネスロジック実行
Recipes::CreateService.invoke(attrs: attrs, user: user)

# Query - 動詞で始める（filter_, search_, order_by_）
RecipesQuery.new.search(keyword).filter_by_favorite(true).order_by_recent

# Policy - アクション名 + ?
policy.update?
policy.destroy?
```

## 5. エラーハンドリング

### 共通エラーハンドラー

```ruby
# app/controllers/concerns/error_handler.rb
module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
    rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
    rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorized
  end

  private

  def handle_standard_error(exception)
    Rails.logger.error(exception.full_message)

    render json: {
      error: {
        type: "internal_server_error",
        message: "サーバーエラーが発生しました"
      }
    }, status: :internal_server_error
  end

  def handle_not_found(exception)
    render json: {
      error: {
        type: "not_found",
        message: "リソースが見つかりません"
      }
    }, status: :not_found
  end

  def handle_record_invalid(exception)
    render json: {
      error: {
        type: "validation_error",
        message: "入力内容に問題があります",
        details: exception.record.errors.messages
      }
    }, status: :unprocessable_entity
  end

  def handle_parameter_missing(exception)
    render json: {
      error: {
        type: "parameter_missing",
        message: "必須パラメータが不足しています",
        details: { parameter: exception.param }
      }
    }, status: :bad_request
  end

  def handle_unauthorized(exception)
    render json: {
      error: {
        type: "forbidden",
        message: "この操作を行う権限がありません"
      }
    }, status: :forbidden
  end

  def render_validation_errors(errors)
    render json: {
      error: {
        type: "validation_error",
        message: "入力内容に問題があります",
        details: errors.messages
      }
    }, status: :unprocessable_entity
  end
end
```

### エラーレスポンス形式

```json
{
  "error": {
    "type": "validation_error",
    "message": "入力内容に問題があります",
    "details": {
      "name": ["を入力してください"],
      "email": ["は既に使用されています"]
    }
  }
}
```

## 6. レスポンス形式

### 成功レスポンス

```json
// 単一リソース
{
  "data": {
    "id": 1,
    "name": "カレーライス",
    "cookingTime": 60
  }
}

// 一覧（ページネーション付き）
{
  "data": [
    { "id": 1, "name": "カレーライス" },
    { "id": 2, "name": "肉じゃが" }
  ],
  "meta": {
    "currentPage": 1,
    "totalPages": 5,
    "totalCount": 100,
    "perPage": 20
  }
}
```

## 7. テスト規約

### ディレクトリ構成

```
spec/
├── requests/
│   └── api/
│       └── v1/
│           ├── recipes_spec.rb
│           └── menus_spec.rb
├── forms/
│   └── recipes/
│       ├── create_form_spec.rb
│       └── update_form_spec.rb
├── services/
│   └── recipes/
│       ├── create_service_spec.rb
│       └── update_service_spec.rb
├── resources/
│   ├── recipe_resource_spec.rb
│   └── menu_resource_spec.rb
├── queries/
│   └── recipes_query_spec.rb
├── policies/
│   └── recipe_policy_spec.rb
└── models/
    ├── recipe_spec.rb
    └── user_spec.rb
```

### テスト例

```ruby
# spec/services/recipes/create_service_spec.rb
RSpec.describe Recipes::CreateService do
  describe ".invoke" do
    let(:user) { create(:user) }
    let(:attrs) do
      {
        name: "カレーライス",
        cooking_time: 60,
        difficulty: 2
      }
    end

    context "正常系" do
      it "レシピを作成できる" do
        result = described_class.invoke(attrs: attrs, user: user)

        expect(result).to be_success
        expect(result.recipe).to be_persisted
        expect(result.recipe.name).to eq "カレーライス"
      end
    end

    context "異常系" do
      let(:invalid_attrs) { { name: "" } }

      it "バリデーションエラー時は失敗する" do
        result = described_class.invoke(attrs: invalid_attrs, user: user)

        expect(result).to be_failure
      end
    end
  end
end
```

---

**更新日**: 2025-12-21
**バージョン**: 1.0
