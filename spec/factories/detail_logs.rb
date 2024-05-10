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
FactoryBot.define do
  factory :detail_log do
    
  end
end
