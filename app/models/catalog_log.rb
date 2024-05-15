# == Schema Information
#
# Table name: catalog_logs
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
#  catalog_id :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_catalog_logs_on_catalog_id  (catalog_id)
#  index_catalog_logs_on_user_id     (user_id)
#
class CatalogLog < ApplicationRecord
  include LinkSource
  belongs_to :user, optional: true
  has_one    :company, through: :user

  belongs_to :catalog

  before_save :check_robot

  KEYWORDSEARCH_COLUMNS = %w[ip host utag].freeze
  KEYWORDSEARCH_SQL = KEYWORDSEARCH_COLUMNS.map { |c| "coalesce(#{c}, '')" }.join(" || ' ' || ") << " ~* ALL(ARRAY[?])"

  scope :where_keyword, ->(keyword) { where(KEYWORDSEARCH_SQL, Machine.to_keywords(keyword)) }
end
