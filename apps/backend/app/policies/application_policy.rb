# frozen_string_literal: true

# Pundit Policy の基底クラス
# 認可ロジック（誰が何をできるか）を担当
class ApplicationPolicy
  attr_reader :user, :record

  # @param user [User] 現在のユーザー
  # @param record [ActiveRecord::Base] 対象のレコード
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

  def new?
    create?
  end

  def update?
    owner?
  end

  def edit?
    update?
  end

  def destroy?
    owner?
  end

  private

  # レコードの所有者かどうか
  # @return [Boolean]
  def owner?
    record.user_id == user.id
  end

  # Scope クラス（コレクションのフィルタリング用）
  class Scope
    attr_reader :user, :scope

    # @param user [User] 現在のユーザー
    # @param scope [ActiveRecord::Relation] 対象のスコープ
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    # フィルタリングされたスコープを返却
    # @return [ActiveRecord::Relation]
    def resolve
      scope.where(user: user)
    end
  end
end
