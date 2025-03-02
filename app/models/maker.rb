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
  scope :search_master_maker, ->(kwd) { format_kwd(kwd); where(maker: kwd).or(where(maker_master: kwd)).or(where(maker_kana: kwd)).distinct.select(:maker_master) }

  def self.search_makers(kwd)
    # kwd = format_kwd(kwd) # 整形

    # if kwd.present?
    #   where(maker_master: search_master_maker(kwd)).pluck(:maker_master, :maker).push(kwd)
    #     .flatten.map { |m| m.gsub(/\(.*\)/, '').strip.split("｜") }.flatten.uniq.compact_blank
    # else
    #   []
    # end

    search_master_maker(kwd).pluck(:maker_master).push(format_kwd(kwd)).flatten.uniq.compact_blank
  end

  def self.makers_keyword(kwd)
    search_makers(kwd).join('|')
  end

  def self.format_kwd(kwd)
    Array(kwd).map { |ma| ma.gsub(/(製)$/, "").gsub(/((合同|有限|株式)会社)|(((鉄|鐵)工|工(作|業)|(製|制)作)所?)/, "") } # 整形
  end
end
