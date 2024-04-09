# == Schema Information
#
# Table name: genres
#
#  id(ジャンルID)                          :integer          not null, primary key
#  capacity_label(能力項目名)              :text
#  capacity_unit(能力単位)                 :text
#  changed_at                              :datetime
#  deleted_at                              :datetime
#  genre(ジャンル名)                       :text
#  genre_kana(ジャンル名（カナ）)          :text
#  naming(命名規則)                        :text
#  order_no(並び順)                        :integer
#  spec_labels(その他能力項目(JSON)	 JSON) :text
#  created_at                              :datetime
#  large_genre_id(大ジャンルID)            :integer          not null
#
# Indexes
#
#  genres_ix1  (large_genre_id)
#
class Genre < ApplicationRecord
  include SoftDelete

  OTHERS_GENRE_ID = 390

  belongs_to :large_genre
  has_one    :xl_genre, through: :large_genre
  has_many   :machines
  has_many   :catalog_genres
  has_many   :catalogs, through: :catalog_genres

  ### value ###
  composed_of :spec_labels_parsed, class_name: "JsonToHash", mapping: %i[spec_labels json]
end
