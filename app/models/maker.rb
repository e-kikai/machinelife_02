# == Schema Information
#
# Table name: makers
#
#  id(メーカーID)               :integer          not null, primary key
#  maker(メーカー名)            :string(200)
#  maker_kana(メーカー名(カナ)) :string(200)
#  maker_master(メーカーマスタ) :string(200)
#
# Indexes
#
#  makers_ix1  (maker)
#  makers_ix2  (maker_master)
#  makers_ix3  (maker_kana)
#
class Maker < ApplicationRecord
  scope :search_master_maker, ->(kwd) { where(maker: kwd).or(where(maker_master: kwd)).or(where(maker_kana: kwd)).select(:maker_master) }

  def self.search_makers(kwd)
    if kwd.present?
      Maker.where(maker_master: search_master_maker(kwd)).pluck(:maker_master, :maker).push(kwd).flatten.map { |m| m.gsub(/\(.*\)/, '').strip.split("｜") }.flatten.uniq.compact_blank
    else
      []
    end
  end

  def self.makers_keyword(kwd)
    search_makers(kwd).join('|')
  end
end
