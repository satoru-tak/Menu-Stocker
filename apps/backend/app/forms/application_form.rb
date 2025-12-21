# frozen_string_literal: true

# Form Object の基底クラス
# 入力値のバリデーションとパラメータ整形を担当
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
  # @return [Hash] { attribute: "エラーメッセージ" }
  def error_messages
    errors.messages.transform_values(&:first)
  end

  # フォームの属性をハッシュで返却
  # @return [Hash]
  def to_h
    attributes.symbolize_keys
  end
end
