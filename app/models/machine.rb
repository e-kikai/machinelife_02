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
#  search_capacity                :text             default("")
#  search_keyword                 :text             default("")
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
#  index_machines_on_addr1   (addr1)
#  index_machines_on_maker2  (maker2)
#  index_machines_on_year    (year)
#  machines_ix1              (deleted_at)
#  machines_ix2              (genre_id)
#  machines_ix3              (maker)
#  machines_ix4              (company_id)
#  machines_ix5              (created_at)
#
class Machine < ApplicationRecord
  include SoftDelete
  include Machine::Scoring

  after_create  :save
  before_update :update_search_keywords

  MEDIA_URL = "https://s3-ap-northeast-1.amazonaws.com/machinelife/machine/public/media/machine/".freeze
  NEWS_LIMIT_DEFAULT = 6
  # NEWS_DAY = Time.current.ago(1.day)
  NEWS_DAY = Time.current.ago(1.week)
  NEWS_MAIL_DAY = Time.current.ago(1.week)
  NEWS_ADMIN_MAIL_DAY = Time.current.ago(1.day)

  NEAR_DAY = Time.current.ago(1.week)

  DEFAULT_SORT =
    [
      "xl_genres.order_no", "large_genres.order_no", "genres.order_no",
      :capacity, :maker2, :model2, :name, :year, :addr1, { created_at: :desc }
    ].freeze

  SORTS = {
    default: ["ジャンル・機械名順", []],
    year_desc: ["年式 : 新しい順", [Arel.sql("coalesce(year, '') !~ '[0-9]{4}' ASC"), { year: :desc }]],
    year_asc: ["年式 : 古い順", [Arel.sql("coalesce(year, '') !~ '[0-9]{4}' ASC"), { year: :asc }]],
    create_desc: ["登録日時 : 新しい順", [created_at: :desc]],
    create_asc: ["登録日時 : 古い順", [created_at: :asc]],
    no_asc: ["管理番号 : 昇順", [Arel.sql("coalesce(no, '') = '' ASC"), { no: :asc }]],
    no_desc: ["管理番号 : 降順", [Arel.sql("coalesce(no, '') = '' ASC"), { no: :desc }]]
  }.freeze

  ### 会員ページでの在庫キーワード検索 ###
  # KEYWORDSEARCH_COLUMNS =
  #   %w[
  #     machines.no machines.name machines.maker machines.model machines.year machines.addr1
  #     machines.model2 machines.maker2
  #     makers.maker_master genres.genre
  #   ].freeze

  KEYWORDSEARCH_COLUMNS =
    %w[
      machines.no machines.name machines.maker machines.model machines.addr1 machines.model2
      machines.addr2 machines.addr3 machines.location
      machines.spec machines.comment machines.accessory
      makers.maker_master genres.genre
    ].freeze
  KEYWORDSEARCH_SQL = "concat_ws('', #{KEYWORDSEARCH_COLUMNS.join(', ')}) ~* ALL(ARRAY[?])".freeze

  belongs_to :company
  belongs_to :genre
  has_one    :large_genre,     through: :genre
  has_one    :xl_genre,        through: :large_genre
  has_many   :machine_nitamonos
  has_many   :nitamonos,       through: :machine_nitamonos, source: :nitamono

  belongs_to :maker_relation,  class_name: "Maker", primary_key: :maker, foreign_key: :maker2, optional: true
  has_one    :maker_m,         through: :maker_relation, class_name: "Maker", primary_key: :maker, foreign_key: :maker_master

  belongs_to :state,           foreign_key: :addr1, optional: true
  has_many   :machine_images
  has_many   :machine_pdfs
  has_many   :catalogs
  has_many   :contacts
  has_many   :detail_logs

  mount_uploader :top_image, MachineImageUploader

  ### enum ###
  enum view_option: { display: nil, hide: 1, negotiation: 2 }
  # enum view_option: { '表示': nil, '非表示': 1, '商談中': 2 }

  ### scope ###
  scope :includes_all, -> { includes(:company, :genre, :large_genre, :xl_genre, :maker_m, :machine_pdfs) }
  scope :sales_status, -> { where(companies: { deleted_at: nil, rank: Company::MACHINE_RANK_RATIO.. }, view_option: [nil, :negotiation]) }
  scope :sales, -> { includes_all.sales_status }
  scope :mai_search_sales, -> { includes(:company, :maker_m).sales_status }

  scope :only_machines, -> { where(large_genre: { xl_genre_id: XlGenre::MACHINE_IDS }) }
  scope :only_tools, -> { where.not(large_genre: { xl_genre_id: XlGenre::MACHINE_IDS }) }

  scope :news, ->(limit = NEWS_LIMIT_DEFAULT) { order(created_at: :desc).limit(limit) }
  scope :order_by_key, ->(key) { order((SORTS[key.to_s.to_sym] || SORTS[:default])[1].concat(DEFAULT_SORT)) }
  scope :where_maker, ->(makers) { merge(Machine.where(maker2: makers).or(Maker.where(maker_master: makers))) }
  scope :where_model2, ->(model) { where("machines.model2 ~* ?", to_model2(model)) }

  scope :where_keyword, ->(keyword) { where(KEYWORDSEARCH_SQL, to_keywords(keyword)) }
  # scope :where_keyword, ->(keyword) { merge(Machine.where("machines.name LIKE ?", "%#{keyword}%").or(Machine.where("machines.maker LIKE ?", "%#{keyword}%"))) }

  # scope :with_images, -> { where("(machines.top_image IS NOT NULL AND machines.top_image <> '') OR (machines.top_img IS NOT NULL AND machines.top_img <> '')") }
  scope :with_images, -> { merge(Machine.where.not(top_image: [nil, ""]).or(Machine.where.not(top_img: [nil, ""]))) }
  scope :without_images, -> { where(top_image: nil, top_img: nil) }
  scope :with_youtube, -> { where.not(youtube: [nil, "", "http://youtu.be/"]) }

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
    year =~ /^([0-9]{4})/ ? "#{::Regexp.last_match(1)}年式" : year
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
    NKF.nkf('-wXZ', keyword).upcase.gsub(%r{[ -/:-@\[-~]}, " ").split(/[[:space:]]/).compact_blank
  end

  def self.to_model2(model)
    NKF.nkf('-wXZ', model.to_s).upcase.gsub(/[^A-Z0-9]*/, "").strip
  end

  def sames
    if model2.present?
      Machine.where(model2:).where.not(id:).where.not(model2: "")
    else
      Machine.none
    end
  end

  def nears(utag)
    near_utags = DetailLog.where(machine_id: id, created_at: NEAR_DAY..).where.not(utag: [utag, nil]).where.not(host: ["", nil]).select(:utag)
    Machine.where(id: DetailLog.where(utag: near_utags, created_at: NEAR_DAY..).select(:machine_id))
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

  def top_image_url(noimage: Media::NOTHING_URL)
    top_image&.url || top_img_media.url(noimage:)
  end

  def top_image_thumb(noimage: Media::NOTHING_URL)
    top_image&.thumb&.url || top_img_media.thumbnail(noimage:)
  end

  def image?
    top_image.present? || top_img.present?
  end

  ######

  # 能力値を開く
  def capacities
    res = {}
    if genre.capacity_label.present?
      val = capacity.present? ? "#{ActiveSupport::NumberHelper.number_to_rounded(capacity, strip_insignificant_zeros: true)}#{genre.capacity_unit}" : nil
      res[genre.capacity_label] = val if val.present?
    end

    others_hash.each_value do |other|
      res[other[:label]] = other[:disp] if other[:disp].present?
    end

    res
  end

  # 能力検索用キーワード整形
  def to_search_capacity
    # "#{name} #{Machine.to_model2(model.to_s)} #{spec} #{capacities.map { |k, v| "#{k}:#{v}" }.join(' ')}".strip
    "#{name} #{model2} #{spec} #{capacities.map { |k, v| "#{k}:#{v}" }.join(' ')}".strip
  end

  # キーワード検索用キーワード整形
  def to_search_keyword
    "#{NKF.nkf('-wXZ', no.to_s).upcase.gsub(/[[:punct:]]/, '')} #{name} #{maker} #{model} #{myear} #{addr1} #{addr2} #{addr3} #{location} #{spec} #{comment} #{accessory} #{model2} #{maker2} #{maker_m.try(:maker_master)} #{capacities.map { |k, v| "#{k}:#{v}" }.join(' ')}".strip
  end

  def update_search_keywords
    self.search_capacity = to_search_capacity
    self.search_keyword  = to_search_keyword
  end

  def self.reset_keyword
    sales.find_each(&:save)
    ActiveRecord::Base.connection.execute "VACUUM FULL ANALYZE machines"
  end

  # 新着判別
  def new?
    created_at >= NEWS_DAY
  end

  # あなたへのおすすめ
  def self.utag_favorites(utag)
    detail_logs_lim = DetailLog.where(created_at: NEAR_DAY..).limit(50)
    utag_logs  = detail_logs_lim.where(utag:).select(:machine_id)
    near_utags = detail_logs_lim.where(machine_id: utag_logs).where.not(utag:).where.not(host: "").select(:utag)

    Machine.where(
      id: detail_logs_lim.where(utag: near_utags).select(:machine_id)
    ).where.not(
      id: DetailLog.where(utag:, created_at: NEAR_DAY..Time.current.beginning_of_day).select(:machine_id)
    )
  end
end
