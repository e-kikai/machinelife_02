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
require 'rails_helper'

RSpec.describe CatalogGenre, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
