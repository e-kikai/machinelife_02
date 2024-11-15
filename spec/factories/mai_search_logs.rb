# == Schema Information
#
# Table name: mai_search_logs
#
#  id                         :bigint           not null, primary key
#  bad(低評価)                :boolean          default(FALSE), not null
#  count(最終結果件数)        :integer          default(0), not null
#  error(エラー)              :text             default(""), not null
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
#  index_mai_search_logs_on_user_id  (user_id)
#
FactoryBot.define do
  factory :mai_search_log do
    
  end
end
