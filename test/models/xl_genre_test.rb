# == Schema Information
#
# Table name: xl_genres
#
#  id(特大ジャンルID)                    :integer          not null, primary key
#  changed_at                            :datetime
#  deleted_at                            :datetime
#  order_no(並び順)                      :integer
#  xl_genre(特大ジャンル名)              :text
#  xl_genre_kana(特大ジャンル名（カナ）) :text
#  created_at                            :datetime
#
require "test_helper"

class XlGenreTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
