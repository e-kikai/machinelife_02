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
class XlGenre < ApplicationRecord
  include SoftDelete

  has_many :large_genres
  has_many :genres, through: :large_genres
  has_many :machines, through: :genres

  MACHINE_IDS = [1, 2, 3, 4, 5, 6].freeze
end
