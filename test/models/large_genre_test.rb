# == Schema Information
#
# Table name: large_genres
#
#  id(大ジャンルID)                       :integer          not null, primary key
#  changed_at                             :datetime
#  deleted_at                             :datetime
#  hide_option(非表示オプション)          :integer
#  large_genre(大ジャンル名)              :text
#  large_genre_kana(大ジャンル名（カナ）) :text
#  order_no(並び順)                       :integer
#  created_at                             :datetime
#  xl_genre_id(特大ジャンルID)            :integer
#
require "test_helper"

class LargeGenreTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
