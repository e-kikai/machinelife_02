# == Schema Information
#
# Table name: miniblogs
#
#  id(ID)               :integer          not null, primary key
#  changed_at(変更日時) :datetime
#  contents(内容)       :text
#  deleted_at(削除日時) :datetime
#  target(対象)         :text
#  created_at(登録日時) :datetime
#  user_id(ユーザID)    :integer          not null
#
FactoryBot.define do
  factory :miniblog do
    
  end
end
