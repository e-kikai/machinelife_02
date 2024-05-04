# == Schema Information
#
# Table name: machines
#
#  id(機械ID)                     :integer          not null, primary key
#  accessory(附属品)              :text
#  addr1(住所(都道府県))          :text
#  addr2(住所(市区町村))          :text
#  addr3(住所(番地その他))        :text
#  capacity(能力)                 :float
#  changed_at(変更日時)           :datetime
#  comment(コメント)              :text
#  commission(試運転)             :integer
#  deleted_at(削除日時)           :datetime
#  ekikai_price                   :integer
#  hint                           :string(200)
#  imgs(画像情報(JSON)	 JSON)     :text
#  lat(緯度)                      :decimal(10, 7)
#  lng(経度)                      :decimal(10, 7)
#  location(在庫場所)             :text
#  location_address(在庫場所住所) :text
#  maker(メーカー)                :text
#  maker2                         :string
#  model(型式)                    :text
#  model2                         :string
#  name(機械名)                   :string(100)
#  no(管理番号)                   :text
#  others(その他能力(JSON)	 JSON) :text
#  pdfs(PDF(JSON))                :text
#  price(金額)                    :integer
#  price_tax                      :integer
#  spec(仕様)                     :text
#  top_image                      :string
#  top_img(トップ画像)            :text
#  used_change                    :integer
#  view_option(表示オプション)    :integer
#  year(年式)                     :text
#  youtube(Youtube ID)            :text
#  created_at(登録日時)           :datetime
#  catalog_id(カタログID)         :integer
#  company_id(会社ID)             :integer          not null
#  genre_id(ジャンルID)           :integer          not null
#  used_id                        :string(200)
#
# Indexes
#
#  machines_ix1  (deleted_at)
#  machines_ix2  (genre_id)
#  machines_ix3  (maker)
#  machines_ix4  (company_id)
#  machines_ix5  (created_at)
#
class Machine < ApplicationRecord
  include SoftDelete

  MEDIA_URL = "https://s3-ap-northeast-1.amazonaws.com/machinelife/machine/public/media/machine/".freeze
  NEWS_LIMIT_DEFAULT = 6
  NEWS_DAY = Time.current.ago(1.day)
  NEWS_MAIL_DAY = Time.current.ago(1.week)
  NEWS_ADMIN_MAIL_DAY = Time.current.ago(1.day)

  SORTS = {
    default: ["ジャンル・機械名順", ["large_genres.order_no", "genres.order_no", :name, { created_at: :desc }]],
    year_desc: ["年式 : 新しい順", [{ year: :desc }, :name, { created_at: :desc }]],
    year_asc: ["年式 : 古い順", [:year, :name, { created_at: :desc }]],
    create_desc: ["登録日時 : 新しい順", [created_at: :desc]],
    create_asc: ["登録日時 : 古い順", [:created_at]]
  }.freeze

  KEYWORDSEARCH_COLUMNS =
    %w[
      machines.name machines.maker machines.model machines.year machines.addr1
      machines.model2 machines.maker2
      makers.maker_master genres.genre
    ].freeze
  KEYWORDSEARCH_SQL = KEYWORDSEARCH_COLUMNS.map { |c| "coalesce(#{c}, '')" }.join(" || ' ' || ") << " ~* ALL(ARRAY[?])"

  belongs_to :company
  belongs_to :genre
  has_one    :large_genre,     through: :genre
  has_one    :xl_genre,        through: :large_genre
  has_many   :machine_nitamono
  has_many   :nitamonos,       through: :machine_nitamono, source: :nitamono
  belongs_to :maker_m,         class_name: "Maker", primary_key: :maker, foreign_key: :maker2, optional: true
  belongs_to :state,           foreign_key: :addr1, optional: true
  has_many   :machine_images
  has_many   :machine_pdfs

  mount_uploader :top_image, MachineImageUploader

  ### enum ###
  enum view_option: { display: nil, hide: 1, negotiation: 2 }
  # enum view_option: { '表示': nil, '非表示': 1, '商談中': 2 }

  ### scope ###
  scope :includes_all, -> { includes(:company, :genre, :large_genre, :xl_genre, :maker_m, :machine_pdfs) }
  scope :sales, -> { includes_all.where(deleted_at: nil, companies: { deleted_at: nil, rank: Company::MACHINE_RANK_RATIO.. }, view_option: [nil, 2]) }

  scope :only_machines, -> { where(large_genre: { xl_genre_id: XlGenre::MACHINE_IDS }) }
  scope :only_tools, -> { where.not(large_genre: { xl_genre_id: XlGenre::MACHINE_IDS }) }

  scope :news, ->(limit = NEWS_LIMIT_DEFAULT) { order(created_at: :desc).limit(limit) }
  scope :order_by_key, ->(key) { order((SORTS[key.to_s.to_sym] || SORTS[:default])[1]) }
  scope :where_maker, ->(makers) { merge(Machine.where(maker2: makers).or(Maker.where(maker_master: makers))) }
  scope :where_model2, ->(model) { where("machines.model2 ~* ?", to_model2(model)) }

  scope :where_keyword, ->(keyword) { where(KEYWORDSEARCH_SQL, to_keywords(keyword)) }

  ### value ###
  composed_of :top_img_media, class_name: "Media", mapping: [%i[top_img file]], constructor: ->(top_img) { Media.new(top_img, MEDIA_URL) }
  composed_of :addr, mapping: [%i[addr1 addr1], %i[addr2 addr2], %i[addr3 addr3]]
  composed_of :others_parsed, class_name: "JsonToHash", mapping: [%i[others jso]]
  composed_of :imgs_parsed, class_name: "JsonToMedias", mapping: [%i[imgs json]], constructor: ->(imgs) { JsonToMedias.new(imgs, MEDIA_URL) }
  composed_of :pdfs_parsed, class_name: "JsonToMedias", mapping: [%i[pdfs json]], constructor: ->(pdfs) { JsonToMedias.new(pdfs, MEDIA_URL) }

  ### methods ###
  def full_name
    "#{maker} #{name} #{model}"
  end

  def myear
    year =~ /^([0-9]+)/ ? "#{::Regexp.last_match(1)}年式" : ""
  end

  def elapsed
    sec = Time.zone.now - created_at

    case sec
    when ..3600;   "#{sec.div(60)}分"
    when ..86_400; "#{sec.div(60 * 60)}時間"
    else;          "#{sec.div(60 * 60 * 24)}日前"
    end
  end

  def youtube_ids
    youtube.to_s.scan(/[\w\-]{11}/)
  end

  def self.selector_sorts
    SORTS.to_h { |k, v| [v[0], k] }
  end

  def self.to_keywords(keyword)
    NKF.nkf('-wXZ', keyword).gsub(%r{[\ -/\:-\@\[-\~]}, " ").upcase.split(/[[:space:]]/).compact_blank
  end

  def self.to_model2(model)
    NKF.nkf('-wXZ', model).upcase.gsub(/[^A-Z0-9]*/, "").strip
  end

  def sames
    if model2.present?
      Machine.where(model2:).where.not(id:).where.not(model2: "")
    else
      Machine.none
    end
  end

  def others_hash
    spec_labels = genre.spec_labels_parsed.datas

    others_parsed.datas.to_h do |key, val|
      label = spec_labels[key]

      disp =
        if val.instance_of?(Array)
          val.any? ? val.map { |v| "#{v}#{label[:unit]}" }.join(" x ") : ""
        elsif label[:label] == "NC装置"
          "メーカー : #{val[:maker]}、 型式 : #{val[:model]}"
        else
          val.present? ? "#{val}#{label[:unit]}" : ""
        end

      [
        key,
        {
          value: val,
          type: label[:type],
          label: label[:label],
          unit: label[:unit],
          disp:
        }
      ]
    end.to_h rescue {}
  end

  def top_image_url
    top_image&.url || top_img_media.url
  end

  def top_image_thumb
    top_image&.thumb&.url || top_img_media.thumbnail
  end
end
