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
class SystemMail < ApplicationRecord
  self.table_name = "mails"

  IGNORES_FILE_PATH = Rails.root.join("crawlers/csv/mail_ignore.csv").to_s.freeze
  WORKINGGROUPS_FILE_PATH = Rails.root.join("crawlers/csv/workinggroup_mails.csv").to_s.freeze
end
