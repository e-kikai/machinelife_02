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
FactoryBot.define do
  factory :search_log do
    
  end
end
