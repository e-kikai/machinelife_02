# == Schema Information
#
# Table name: users
#
#  id(ユーザID)              :integer          not null, primary key
#  account                   :text
#  changed_at(変更日時)      :datetime
#  deleted_at(削除日時)      :datetime
#  fax(FAX)                  :text
#  mail(メールアドレス)      :text
#  passwd(パスワード（MD5）) :text
#  passwd_changed_at         :datetime
#  role(権限)                :text
#  tel(TEL)                  :text
#  user_name(ユーザ名)       :text
#  created_at(登録日時)      :datetime
#  company_id(会社ID)        :integer
#
class User < ApplicationRecord
  include SoftDelete

  belongs_to :company, optional: true

  SELECT_ROLES = {
    '権限なし': :guest,
    '一般ユーザ': :user,
    '電子カタログのみユーザ': :catalog,
    '全機連会員': :member,
    '管理者': :system,
  }
end
