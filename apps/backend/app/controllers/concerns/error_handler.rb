# frozen_string_literal: true

# エラーハンドリング用の Concern
# 各種例外を捕捉して適切なJSONレスポンスを返却
module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
    rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
    rescue_from Pundit::NotAuthorizedError, with: :handle_forbidden
  end

  private

  # 予期しないエラー
  def handle_standard_error(exception)
    Rails.logger.error(exception.full_message)

    render json: {
      error: {
        type: "internal_server_error",
        message: "サーバーエラーが発生しました"
      }
    }, status: :internal_server_error
  end

  # レコードが見つからない
  def handle_not_found(_exception)
    render json: {
      error: {
        type: "not_found",
        message: "リソースが見つかりません"
      }
    }, status: :not_found
  end

  # バリデーションエラー（ActiveRecord）
  def handle_record_invalid(exception)
    render json: {
      error: {
        type: "validation_error",
        message: "入力内容に問題があります",
        details: exception.record.errors.messages
      }
    }, status: :unprocessable_entity
  end

  # パラメータ不足
  def handle_parameter_missing(exception)
    render json: {
      error: {
        type: "parameter_missing",
        message: "必須パラメータが不足しています",
        details: { parameter: exception.param }
      }
    }, status: :bad_request
  end

  # 認可エラー（Pundit）
  def handle_forbidden(_exception)
    render json: {
      error: {
        type: "forbidden",
        message: "この操作を行う権限がありません"
      }
    }, status: :forbidden
  end

  # バリデーションエラー（Form Object用）
  # @param errors [ActiveModel::Errors] エラーオブジェクト
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
