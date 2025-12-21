# frozen_string_literal: true

# Query Object の基底クラス
# 複雑な検索条件のカプセル化を担当
class ApplicationQuery
  attr_reader :relation

  # @param relation [ActiveRecord::Relation] 対象のリレーション
  def initialize(relation = default_relation)
    @relation = relation
  end

  # リレーションを返却（メソッドチェーン終端）
  # @return [ActiveRecord::Relation]
  def result
    @relation
  end

  # Kaminari ページネーション
  # @param page_number [Integer] ページ番号
  # @param per_page [Integer] 1ページあたりの件数
  # @return [self]
  def page(page_number, per_page: 20)
    @relation = @relation.page(page_number).per(per_page)
    self
  end

  private

  # デフォルトのリレーション（サブクラスで実装）
  # @return [ActiveRecord::Relation]
  def default_relation
    raise NotImplementedError, "#{self.class}#default_relation を実装してください"
  end
end
