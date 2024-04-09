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
require "test_helper"

class GenreTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
