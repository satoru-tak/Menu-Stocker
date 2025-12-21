# frozen_string_literal: true

# Service の基底クラス
# ビジネスロジックとトランザクション管理を担当
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
  # @return [Result] 成功時は success(data)、失敗時は failure(error)
  def invoke
    raise NotImplementedError, "#{self.class}#invoke を実装してください"
  end

  private

  # 成功結果を返却
  # @param data [Hash] 結果データ
  # @return [Result]
  def success(data = {})
    Result.new(success?: true, data: data)
  end

  # 失敗結果を返却
  # @param error [String, Hash] エラー情報
  # @return [Result]
  def failure(error)
    Result.new(success?: false, error: error)
  end
end
