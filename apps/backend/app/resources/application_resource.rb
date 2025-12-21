# frozen_string_literal: true

# Alba Resource の基底クラス
# JSON シリアライズを担当
class ApplicationResource
  include Alba::Resource

  # キーをキャメルケースに変換（JavaScript フレンドリー）
  transform_keys :lower_camel

  # 日時属性のヘルパーメソッド
  # ISO8601 形式で出力
  # @param name [Symbol] 属性名
  def self.timestamp(name)
    attribute name do |resource|
      resource.public_send(name)&.iso8601
    end
  end

  # 日付属性のヘルパーメソッド
  # YYYY-MM-DD 形式で出力
  # @param name [Symbol] 属性名
  def self.date_attribute(name)
    attribute name do |resource|
      resource.public_send(name)&.strftime("%Y-%m-%d")
    end
  end
end
