class System::CatalogForm < FormBase
  attribute :uid, :integer
  attribute :maker, :string
  attribute :maker_kana, :string
  attribute :year, :string
  attribute :catalog_no, :string
  attribute :models, :string
  attribute :genre_ids, default: []

  delegate :id, :persisted?, to: :catalog

  ### validater ###
  validates_presence_of %w[uid maker maker_kana]
  validate :check_pdf_file

  UPLOAD_DIR = "/tmp/".freeze

  SLICE_ATTRS = %w[uid maker maker_kana year catalog_no models genre_ids].freeze

  def initialize(attributes = nil, catalog: nil)
    @catalog = catalog || Catalog.find_or_initialize_by(uid: attributes[:uid])
    super(attributes)
  end

  def persist
    # ファイルのアップロード

    # サムネイル画像の作成

    attrs = {
      keywords: Machine.to_model2(models), # 検索キーワード
      file: pdf_file_name,
      thumbnail: thumbnail_file_name,
      canged_at: Time.current,
      deleted_at: nil
    }

    contact.update!(slice(SLICE_ATTRS).merge(attrs))
  end

  def pdf_file_name
    "#{uid}.pdf"
  end

  def thumbnail_file_name
    "#{uid}.jpeg"
  end

  private

  attr_reader :bidinfo

  def default_attributes
    catalog.slice(SLICE_ATTRS)
  end

  def check_pdf_file
    errors.add(:other_message, "PDFファイルがありません") if File.exist?("UPLOAD_DIR#{catalog.file}")
  end
end
