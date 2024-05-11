# == Schema Information
#
# Table name: detail_logs
#
#  id         :bigint           not null, primary key
#  host       :string           default("")
#  ip         :string           default("")
#  r          :string           default(""), not null
#  referer    :string           default("")
#  ua         :string           default("")
#  utag       :string           default("")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  machine_id :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_detail_logs_on_machine_id  (machine_id)
#  index_detail_logs_on_user_id     (user_id)
#
class DetailLog < ApplicationRecord
  include LinkSource
  belongs_to :user, optional: true
  has_one    :company, through: :user

  belongs_to :machine
  has_one    :genre, through: :machine
  has_one    :large_genre, through: :genre
  has_one    :xl_genre, through: :large_genre

  before_save :check_robot

  KEYWORDSEARCH_COLUMNS = %w[ip host utag].freeze
  KEYWORDSEARCH_SQL = KEYWORDSEARCH_COLUMNS.map { |c| "coalesce(#{c}, '')" }.join(" || ' ' || ") << " ~* ALL(ARRAY[?])"

  scope :where_keyword, ->(keyword) { where(KEYWORDSEARCH_SQL, to_keywords(keyword)) }

  def self.to_keywords(keyword)
    NKF.nkf('-wXZ', keyword).upcase.gsub(%r{[ -/:-@\[-~]}, " ").split(/[[:space:]]/).compact_blank
  end
end
