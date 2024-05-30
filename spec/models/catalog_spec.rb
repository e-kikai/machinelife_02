# == Schema Information
#
# Table name: catalogs
#
#  id(カタログID)                          :integer          not null, primary key
#  catalog_no                              :text
#  changed_at(変更日時)                    :datetime
#  deleted_at(削除日時)                    :datetime
#  file(カタログファイル名	 PDFファイル名) :text
#  keywords(検索キーワード	 部分一致)      :text
#  maker(メーカー)                         :text
#  maker_kana(メーカー(カナ)	 テキスト用)  :text
#  models(型式群)                          :text
#  pdf                                     :string
#  thumbnail(サムネイル画像ファイル名)     :text
#  uid(ユニークキー)                       :text             not null
#  year(年代)                              :text
#  created_at(登録日時)                    :datetime
#
# Indexes
#
#  catalogs_ix1  (models)
#  catalogs_ix2  (maker)
#
require 'rails_helper'

RSpec.describe Catalog, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
