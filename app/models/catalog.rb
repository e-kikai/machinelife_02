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
class Catalog < ApplicationRecord
  include SoftDelete
  require 'nkf'

  MEDIA_URL = "https://s3-ap-northeast-1.amazonaws.com/machinelife/media/catalog/".freeze
  TUMBNAIL_MEDIA_URL = "https://s3-ap-northeast-1.amazonaws.com/machinelife/catalog/public/media/catalog_thumb/".freeze

  has_many :catalog_genres
  has_many :genres, through: :catalog_genres

  ### value ###
  composed_of :file_media, class_name: "Media", mapping: [%i[file file]], constructor: ->(file) { Media.new(file, MEDIA_URL) }
  composed_of :thumbnail_media, class_name: "Media", mapping: [%i[thumbnail file]], constructor: ->(thumbnail) { Media.new(thumbnail, TUMBNAIL_MEDIA_URL) }

  ### scope ###
  scope :where_keyword, ->(keyword) { where("keywords ILIKE ?", "%#{to_keywords(keyword)}%") }

  def self.to_keywords(models)
    NKF.nkf('-wXZ', models).upcase.gsub(/[^A-Z0-9\s]*/, "").strip
  end
end
