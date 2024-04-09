class Admin::CompanyForm < FormBase
  attribute :officer, :string
  attribute :contact_tel, :string
  attribute :contact_fax, :string
  attribute :contact_mail, :string

  attribute :info_pr, :string
  attribute :info_comment, :string
  attribute :info_access_train, :string
  attribute :info_access_car, :string
  attribute :info_opening, :string
  attribute :info_holiday, :string
  attribute :info_license, :string

  attribute :offices, default: []

  attribute :top_image
  attribute :top_image_delete, :boolean
  attribute :images, default: []
  attribute :images_delete, default: []
  attribute :images_cancel, default: []

  attribute :imgs_delete, default: []

  delegate :id, :persisted?, :top_img_media, :imgs_parsed, :top_image_url, :company_images, to: :company

  ### validater ###
  validates_presence_of %i[officer contact_tel contact_fax]

  SLICE_ATTRS = %i[officer contact_tel contact_fax contact_mail].freeze

  def initialize(attributes = nil, company: Company.new)
    @company = company
    super(attributes)
  end

  def persist
    # その他情報
    infos = {
      pr: info_pr,
      comment: info_comment,
      access_train: info_access_train,
      access_car: info_access_car,
      opening: info_opening,
      holiday: info_holiday,
      license: info_license
    }.to_json

    # 営業所
    tmp = offices.reject { |o| o[:name].blank? }.to_json

    # トップ画像処理
    if top_image.present?
      company.top_image = top_image
    elsif top_image_delete == true
      company.top_image = nil
      company.top_img = nil
    end

    # 旧画像削除
    company.imgs = (imgs_parsed.datas - imgs_delete).to_json if imgs_delete.present?

    # 保存
    company.update!(slice(SLICE_ATTRS).merge({ changed_at: Time.current, infos:, offices: tmp }))

    # 新画像処理
    images.each do |im|
      next if im.blank?
      next if images_cancel.include? im.original_filename # 削除(アップロードしない)

      company.company_images.create(image: im)
    end

    # 新画像削除
    # images_delete.each do |im|
    #   company.company_images.find_by(image: im)&.soft_delete
    # end
    company.company_images.where(id: images_delete).soft_delete_all
  end

  private

  attr_reader :company

  def default_attributes
    office_forms = company.offices_parsed.datas.filter_map do |ofc|
      next if ofc[:name].blank?

      Admin::CompanyOfficeForm.new(company_office: ofc)
    end << Admin::CompanyOfficeForm.new

    company.slice(SLICE_ATTRS).merge(
      {
        info_pr: @company.infos_parsed.datas[:pr],
        info_comment: @company.infos_parsed.datas[:comment],
        info_access_train: @company.infos_parsed.datas[:access_train],
        info_access_car: @company.infos_parsed.datas[:access_car],
        info_opening: @company.infos_parsed.datas[:opening],
        info_holiday: @company.infos_parsed.datas[:holiday],
        info_license: @company.infos_parsed.datas[:license],
        offices: office_forms
      }
    )
  end
end
