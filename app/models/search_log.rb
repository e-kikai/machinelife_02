# == Schema Information
#
# Table name: search_logs
#
#  id         :bigint           not null, primary key
#  count      :integer          default(0)
#  host       :string           default("")
#  ip         :string           default("")
#  page       :integer          default(1)
#  path       :string           default("")
#  r          :string           default(""), not null
#  referer    :string           default("")
#  ua         :string           default("")
#  utag       :string           default("")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_search_logs_on_user_id  (user_id)
#
class SearchLog < ApplicationRecord
  include LinkSource
  belongs_to :user, optional: true
  has_one    :company, through: :user

  before_save :check_robot

  KEYWORDSEARCH_SQL = %w[ip host utag].map { |c| "coalesce(#{c}, '')" }.join(" || ' ' || ") << " ~* ALL(ARRAY[?])"
  scope :where_keyword, ->(keyword) { where(KEYWORDSEARCH_SQL, Machine.to_keywords(keyword)) }
end
