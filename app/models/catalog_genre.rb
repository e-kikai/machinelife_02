# == Schema Information
#
# Table name: catalog_genre
#
#  id(リレーションID)     :integer          not null, primary key
#  catalog_id(カタログID) :integer          not null
#  genre_id(ジャンルID)   :integer          not null
#
# Indexes
#
#  catalog_genre_ix1  (catalog_id)
#  catalog_genre_ix2  (genre_id)
#  catalog_genre_ix3  (catalog_id,genre_id) UNIQUE
#
class CatalogGenre < ApplicationRecord
  self.table_name = :catalog_genre

  belongs_to :catalog
  belongs_to :genre
end
