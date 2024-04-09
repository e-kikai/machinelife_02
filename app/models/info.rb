# == Schema Information
#
# Table name: infos
#
#  id(ID)               :integer          not null, primary key
#  changed_at(変更日時) :datetime
#  contents(内容)       :text
#  deleted_at(削除日時) :datetime
#  info_date(表示日付)  :date
#  target(対象)         :string(200)
#  created_at(登録日時) :datetime
#  group_id(団体ID)     :integer
#
# Indexes
#
#  infos_ix1  (info_date)
#
class Info < ApplicationRecord
  include SoftDelete

  SELECT_TARGETS = {
    '会員ページ': :member,
    '中古機械情報': :machine,
    '電子カタログ': :catalog,
  }
end
