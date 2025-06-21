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
  belongs_to :maker_m, class_name: "Maker", foreign_key: :maker_master, primary_key: :maker, optional: true
  belongs_to :child_makers, class_name: "Maker", foreign_key: :maker_master, primary_key: :maker, optional: true

  scope :search_master_maker, ->(kwd) { format_kwd(kwd); where(maker: kwd).or(where(maker_master: kwd)).or(where(maker_kana: kwd)).distinct.select(:maker_master) }

  KANA_GROUP_REGEX = {
    "ア行" => "^[アイウエオァィゥェォあいうえおぁぃぅぇぉ]",
    "カ行" => "^[カキクケコガギグゲゴかきくけこがぎぐげご]",
    "サ行" => "^[サシスセソザジズゼゾさしすせそざじずぜぞ]",
    "タ行" => "^[タチツテトダヂヅデドたちつてとだぢづでど]",
    "ナ行" => "^[ナニヌネノなにぬねの]",
    "ハ行" => "^[ハヒフヘホバビブベボパピプペポはひふへほばびぶべぼぱぴぷぺぽ]",
    "マ行" => "^[マミムメモまみむめも]",
    "ヤ行" => "^[ヤユヨャュョやゆよゃゅょ]",
    "ラ行" => "^[ラリルレロらりるれろ]",
    "ワ行" => "^[ワヲンヴわをんゔ]",

    # 番外：未分類系
    "未分類(漢字)" => "^[一-龯々〆ヵヶ]",
    "未分類(英数)" => "^[A-Za-z0-9]"
  }.freeze

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
