# == Schema Information
#
# Table name: mai_search_logs
#
#  id                         :bigint           not null, primary key
#  bad(低評価)                :boolean          default(FALSE), not null
#  count(最終結果件数)        :integer          default(0), not null
#  error(エラー)              :text             default(""), not null
#  filters                    :string           default(""), not null
#  good(高評価)               :boolean          default(FALSE), not null
#  host                       :string           default("")
#  ip                         :string           default("")
#  keywords(検索キーワード)   :string           default(""), not null
#  message(質問文)            :string           default(""), not null
#  r                          :string           default(""), not null
#  referer                    :string           default("")
#  report(レポート)           :text             default(""), not null
#  search_count(検索結果件数) :integer          default(0), not null
#  search_level(検索レベル)   :integer          default(0), not null
#  time(処理時間)             :float            default(0.0), not null
#  ua                         :string           default("")
#  utag                       :string           default("")
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  user_id                    :bigint
#
# Indexes
#
#  index_mai_search_logs_on_message  (message)
#  index_mai_search_logs_on_user_id  (user_id)
#
class MaiSearchLog < ApplicationRecord
  include LinkSource
  belongs_to :user, optional: true
  has_one    :company, through: :user

  before_save :check_robot

  SEARCH_RANGE_DATE = 1.month
  BORDER_DATETIME   = "2025/2/20 2:00".freeze

  scope :message_cache, ->(message) { where(message:, created_at: SEARCH_RANGE_DATE.ago..).where(created_at: BORDER_DATETIME.in_time_zone..).order(id: :desc) }
end
