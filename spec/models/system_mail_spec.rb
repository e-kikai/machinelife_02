# == Schema Information
#
# Table name: mails
#
#  id(メールID)            :integer          not null, primary key
#  file(添付ファイル名)    :text
#  message(内容)           :text
#  send_count(送信数)      :integer
#  subject(タイトル)       :text
#  target(送信対象)        :text
#  val(検索値)             :text
#  val_label(検索値ラベル) :text
#  created_at(登録日時)    :datetime
#
# Indexes
#
#  mails_ix1  (val)
#
require 'rails_helper'

RSpec.describe SystemMail, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
