# == Schema Information
#
# Table name: bidinfos
#
#  id(情報ID)                     :integer          not null, primary key
#  banner_file(バナーファイル)    :text
#  banner_image                   :string
#  bid_date(入札日時)             :datetime
#  bid_name(入札会名)             :text
#  changed_at(変更日時)           :datetime
#  comment(コメント)              :text
#  deleted_at(削除日時)           :datetime
#  organizer(主催者名)            :text
#  place(開催場所)                :text
#  preview_end_date(下見終了日)   :date
#  preview_start_date(下見開始日) :date
#  uri(リンク先)                  :text
#  created_at(登録日時)           :datetime
#
# Indexes
#
#  bidinfos_ix1  (preview_start_date)
#  bidinfos_ix2  (preview_end_date)
#  bidinfos_ix3  (bid_date)
#
class Bidinfo < ApplicationRecord
  include SoftDelete

  ### uploader ###
  mount_uploader :banner_image, BannerImageUploader

  MEDIA_URL = "https://s3-ap-northeast-1.amazonaws.com/machinelife/machine/public/media/banner/".freeze

  BOTTOM_BANNERS = [
    ['大阪機械団地組合', 'ad_omdc.png',     'http://www.omdc.or.jp/'],
    ['大阪機械業連合会', 'ad_daikiren.png', 'http://www.zenkiren.org/index.php?%E5%A4%A7%E9%98%AA%E6%A9%9F%E6%A2%B0%E6%A5%AD%E9%80%A3%E5%90%88%E4%BC%9A'],
    ['中部機械業連合会', 'ad_chukiren.png', 'http://www.zenkiren.org/index.php?%E4%B8%AD%E9%83%A8%E6%A9%9F%E6%A2%B0%E6%A5%AD%E9%80%A3%E5%90%88%E4%BC%9A'],
    ['東京機械業連合会', 'ad_toukiren.png', 'http://www.zenkiren.org/index.php?%E6%9D%B1%E4%BA%AC%E6%A9%9F%E6%A2%B0%E6%A5%AD%E9%80%A3%E5%90%88%E4%BC%9A']
  ].freeze

  HEADER_BANNERS = [
    ['東信機工', 'ad_toshin.png', 'https://www.t-mt.com/'],
    ['遠藤機械', 'banner_189.gif', 'https://www.endo-kikai.co.jp/'],
    ['小林機械', 'ad_kobayashi.png', 'https://www.kkmt.co.jp/'],
    ['平井鈑金機工', 'ad_hirai.png', 'http://www.hiraibankin.com/'],
    ['楠本機械', 'ad_kusumoto.png', 'https://kusumotokikai.co.jp/'],
    ['三和精機', 'ad_sanwa_02.gif', 'https://sanwa-seiki.jp/'],
    ['堀川機械', 'ad_horikawa.png', 'https://horikawakikai.e-kikai.com/'],
    ['アイダエンジニアリング株式会社 中古機グループ', 'ad_aida.gif', 'https://www.aida.co.jp/products/used.html'],
    ['新明和機工', 'ad_smk.gif', 'http://www.k-smk.co.jp/'],
    ['伊吹産業', 'ad_ibuki.png', 'http://www.ibuki-in.co.jp/'],
    ['東京エンジニアリング', 'ad_t-eng.gif', 'http://www.t-eng.co.jp/'],
    ['エム・ケイ', 'mk4.gif', 'http://www.matsubarakikai.com/'],
    ['メカニー', 'mechany.gif', 'https://www.mechany.com/'],
    ['アジアマシナリー', 'asia.png', 'https://www.asia-machinery.co.jp/'],
    ['森鉄工所', 'mori.gif', 'https://moritekkousho.jp/']
  ].freeze

  HEADER_BANNERS_LIMIT = 10

  ### value ###
  composed_of :banner_file_media, class_name: "Media", mapping: [%i[banner_file file]], constructor: ->(banner_file) { Media.new(banner_file, MEDIA_URL) }
end
