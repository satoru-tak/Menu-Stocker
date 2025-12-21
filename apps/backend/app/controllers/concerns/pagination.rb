# frozen_string_literal: true

# ページネーション用の Concern
# Kaminari のページネーション情報をメタデータとして返却
module Pagination
  extend ActiveSupport::Concern

  private

  # ページネーションメタ情報を生成
  # @param collection [ActiveRecord::Relation] ページネーション済みコレクション
  # @return [Hash]
  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count,
      per_page: collection.limit_value
    }
  end
end
