# == Schema Information
#
# Table name: companies
#
#  id(会社ID)                              :integer          not null, primary key
#  addr1(住所)                             :text
#  addr2(住所(市区町村))                   :text
#  addr3(住所(番地その他))                 :text
#  bid_entries(入札会出品登録)             :text
#  changed_at(変更日時)                    :datetime
#  company(会社名)                         :text
#  company_kana(会社名（カナ）)            :text
#  contact_fax(問い合わせFAX)              :text
#  contact_mail(問い合わせメールアドレス)  :text
#  contact_tel(問い合わせTEL)              :text
#  deleted_at(削除日時)                    :datetime
#  ekikai_order                            :integer
#  ekikai_subdomain                        :text
#  fax(FAX)                                :text
#  imgs(画像情報(JSON))                    :text
#  infos(情報(JSON)	 項目は設定ファイルで) :text
#  lat(緯度)                               :decimal(10, 7)
#  lng(経度)                               :decimal(10, 7)
#  mail(メールアドレス)                    :text
#  officer(担当者名)                       :text
#  offices(営業所情報(JSON))               :text
#  rank                                    :integer          default(NULL)
#  representative(代表者)                  :text
#  tel(TEL)                                :text
#  top_image                               :string
#  top_img(トップ画像)                     :text
#  website(ウェブサイトアドレス)           :text
#  zip(郵便番号)                           :text
#  created_at(登録日時)                    :datetime
#  ekikai_id                               :integer
#  group_id(団体ID)                        :integer
#  parent_company_id                       :integer
#
class Company < ApplicationRecord
  include SoftDelete

  MEDIA_URL = "https://s3-ap-northeast-1.amazonaws.com/machinelife/machine/public/media/company/".freeze

  KANA_INDEXES = %w[ア カ サ タ ナ ハ マ ヤ ラ ワ].freeze

  MACHINE_RANK_RATIO = 200

  has_many   :machines
  belongs_to :group
  has_one    :parent, through: :group
  has_many   :users
  belongs_to :parent_company, class_name: "Company", optional: true
  has_many   :company_images

  mount_uploader :top_image, CompanyImageUploader

  ### enum ###
  enum rank: {
    c_member: nil,
    b_member: 100,
    a_member: 200,
    branch: 201,
    special: 202
  }

  RANKS_JA = {
    c_member: "C会員",
    b_member: "B会員",
    a_member: "A会員",
    branch: "支店・営業所",
    special: "特別会員"
  }.freeze

  ### value ###
  composed_of :top_img_media, class_name: "Media", mapping: [%i[top_img file]], constructor: ->(top_img) { Media.new(top_img, MEDIA_URL) }
  composed_of :addr, mapping: [%i[addr1 addr1], %i[addr2 addr2], %i[addr3 addr3]]
  composed_of :infos_parsed, class_name: "JsonToHash", mapping: [%i[infos json]]
  composed_of :imgs_parsed, class_name: "JsonToMedias", mapping: [%i[imgs json]], constructor: ->(imgs) { JsonToMedias.new(imgs, MEDIA_URL) }
  composed_of :offices_parsed, class_name: "JsonToHash", mapping: [%i[offices json]]

  ### methods ###
  def company_remove_kabu
    company.gsub(/[（(][株有][）)]|株式会社|有限会社/, "")
  end

  def self.selector_companies
    Company.order(:id).pluck(:company, :id)
  end

  def zip_hyphen
    zip.gsub(/[^0-9]/, "").insert(3, "-")
  end

  def check_rank(target_rank)
    Company.ranks[rank] >= Company.ranks[target_rank]
  end

  def rank_ja
    RANKS_JA[rank.to_sym]
  end

  def top_image_url
    top_image&.url || top_img_media.url
  end
end
