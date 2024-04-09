# == Schema Information
#
# Table name: catalog_requests
#
#  comment(コメント)        :text
#  maker(メーカー)          :text
#  model(型式)              :text
#  send_count(送信数)       :integer
#  target(対象)             :text
#  created_at(登録日時)     :datetime
#  request_id(リクエストID) :integer          not null, primary key
#  user_id(ユーザID)        :integer
#
# Indexes
#
#  catalog_requests_ix1  (comment)
#  catalog_requests_ix2  (user_id)
#
require 'rails_helper'

RSpec.describe CatalogRequest, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
