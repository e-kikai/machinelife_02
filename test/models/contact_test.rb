# == Schema Information
#
# Table name: contacts
#
#  id(問い合わせID)                      :integer          not null, primary key
#  addr1                                 :text
#  fax(FAX)                              :text
#  host                                  :string           default("")
#  ip                                    :string           default("")
#  mail(メールアドレス)                  :text
#  mailuser_flag                         :integer
#  message(内容)                         :text
#  r                                     :string           default(""), not null
#  referer                               :string           default("")
#  return(連絡方法	 JSON)                :integer
#  return_time(時間帯)                   :text
#  tel(TEL)                              :text
#  ua                                    :string           default("")
#  user_company                          :text
#  user_name(ユーザ名	 問い合わせユーザ) :text
#  utag                                  :string           default("")
#  created_at(登録日時)                  :datetime
#  company_id(会社ID)                    :integer
#  machine_id(機械ID)                    :integer
#  user_id(ユーザID	 問い合わせユーザ)   :integer
#
# Indexes
#
#  contacts_company_id_idx       (company_id)
#  contacts_ix1                  (company_id)
#  index_contacts_on_created_at  (created_at)
#  index_contacts_on_machine_id  (machine_id)
#
require "test_helper"

class ContactTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
