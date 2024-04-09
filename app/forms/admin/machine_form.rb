class Admin::MachineForm < FormBase
  attribute :no, :string
  attribute :name, :string
  attribute :maker, :string
  attribute :model, :string
  attribute :year, :string
  attribute :spec, :string
  attribute :accessory, :string
  attribute :comment, :string
  attribute :location, :string
  attribute :addr1, :string
  attribute :addr2, :string
  attribute :addr3, :string
  attribute :capacity, :float
  attribute :catalog_id,:integer
  attribute :genre_id, :integer
  attribute :commission, :integer
  attribute :price, :integer
  attribute :price_tax, :integer
  attribute :youtube, :string
  attribute :view_option, :string
  attribute :others, default: []

  attribute :top_image
  attribute :top_image_delete, :boolean
  attribute :images, default: []
  attribute :images_delete, default: []
  attribute :images_cancel, default: []

  attribute :pdfs, default: []
  attribute :pdfs_filename, default: []
  attribute :pdfs_name, default: []
  attribute :pdfs_delete, default: []
  attribute :pdfs_cancel, default: []
  attribute :pdfs_rename, default: []
  attribute :pdfs_rename_id, default: []

  attribute :imgs_delete, default: []

  attribute :machine_pdfs

  delegate :id, :persisted?, :top_img_media, :imgs_parsed, :pdfs_parsed, :top_image_url, :machine_images, :others_hash, :genre, to: :machine

  SLICE_ATTRS =
    %i[
      no name maker model year spec accessory comment location addr1 addr2 addr3
      capacity catalog_id genre_id commission price price_tax youtube view_option
    ].freeze

  ### validater ###
  validates_presence_of %i[name genre_id]

  def initialize(attributes = nil, machine: Machine.new)
    @machine = machine
    super(attributes)
  end

  def persist
    # トップ画像処理
    if top_image.present?
      machine.top_image = top_image
    elsif top_image_delete == true
      machine.top_image = nil
      machine.top_img = nil
    end

    # 旧画像削除
    machine.imgs = (imgs_parsed.datas - imgs_delete).to_json if imgs_delete.present?

    # 保存
    machine.update!(slice(SLICE_ATTRS).merge({ changed_at: Time.current, others: others.to_json }))

    # 新画像処理
    images.each do |im|
      next if im.blank?
      next if images_cancel.include? im.original_filename # 削除(アップロードしない)

      machine.machine_images.create(image: im)
    end

    # 新画像削除
    machine.machine_images.where(id: images_delete).soft_delete_all if images_delete.present?

    # 新PDF処理
    names = pdfs_filename.zip(pdfs_name).to_h
    pdfs.each do |pdf|
      next if pdf.blank?
      next if pdfs_cancel.include? pdf.original_filename # 削除(アップロードしない)

      machine.machine_pdfs.create(pdf:, name: names[pdf.original_filename] || "")
    end

    # 新PDF更新(削除)
    puts machine_pdfs
    machine_pdfs.each do |id, v|
      machine.machine_pdfs.find_by(id:)&.update!(v)
    end

    true
  end

  # ジャンル選択肢
  def select_xl_genre_large_genres
    XlGenre.includes(:large_genres).order(:order_no)
  end

  def select_large_genre_genres
    LargeGenre.includes(:genres).order(:xl_genre_id, :order_no)
  end

  # 年式選択肢
  def select_years
    (1900..Date.current.year).to_a.reverse.map do |y|
      gengo =
        case y
        when 2019..; "令和#{y == 2019 ? "元" : y - 2018}年"
        when 1989..; "平成#{y == 1989 ? "元" : y - 1988}年"
        when 1926..; "昭和#{y == 1926 ? "元" : y - 1925}年"
        when 1912..; "大正#{y == 1912 ? "元" : y - 1911}年"
        else;        "明治#{y - 1867}年"
        end
      ["#{y} (#{gengo})", y]
    end
  end

  def select_price_taxes
    [
      ["仲間価格(税込価格)", nil],
      ["仲間価格(税抜き)", 1],
      ["ユーザ価格(税込価格)", 2],
      ["ユーザ価格(税抜き)", 3]
    ]
  end

  private

  attr_reader :machine

  def default_attributes
    machine.slice(SLICE_ATTRS).merge(machine_pdfs: machine.machine_pdfs)
  end
end
