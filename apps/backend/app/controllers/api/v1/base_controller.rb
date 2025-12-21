# frozen_string_literal: true

module Api
  module V1
    # API v1 の基底コントローラー
    # 認証・認可・エラーハンドリング・レスポンス形式を共通化
    class BaseController < ApplicationController
      include ErrorHandler
      include Pagination
      include Pundit::Authorization

      # 認証が必要なアクション（サブクラスで skip_before_action 可能）
      before_action :authenticate_user!

      # Pundit の認可チェック漏れを検知（開発時のみ）
      after_action :verify_authorized, except: :index
      after_action :verify_policy_scoped, only: :index

      private

      # 成功レスポンス（200 OK）
      # @param data [Hash, Array] レスポンスデータ
      # @param status [Symbol] HTTPステータス
      # @param meta [Hash] メタ情報
      def render_success(data, status: :ok, meta: {})
        response = { data: data }
        response[:meta] = meta if meta.present?
        render json: response, status: status
      end

      # 作成成功レスポンス（201 Created）
      # @param data [Hash] レスポンスデータ
      def render_created(data)
        render json: { data: data }, status: :created
      end

      # 削除成功レスポンス（204 No Content）
      def render_no_content
        head :no_content
      end
    end
  end
end
