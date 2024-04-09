class Admin::UrikaiForm < FormBase
  attribute :goal, :string
  attribute :contents, :string
  attribute :tel, :string
  attribute :fax, :string
  attribute :mail, :string

  attribute :images, default: []
  attribute :images_delete, default: []
  attribute :images_cancel, default: []

  delegate :id, :persisted?, :urikai_images, to: :urikai

  ### validater ###
  validates_presence_of %i[goal contents]

  SLICE_ATTRS = %w[goal contents tel fax mail].freeze

  def initialize(attributes = nil, urikai: Urikai.new, company: nil)
    @urikai = urikai
    @company = company
    super(attributes)
  end

  def persist
    # 格納
    urikai.update!(slice(SLICE_ATTRS).merge({ company: @company }))

    # 新画像処理
    images.each do |im|
      next if im.blank?
      next if images_cancel.include? im.original_filename # 削除(アップロードしない)

      urikai.urikai_images.create(image: im)
    end

    # メール送信先一覧
    companies = Company.where.not(mail: nil).where.not(id: @company.id)

    # メール送信
    companies.each do |co|
      UrikaiMailer.urikai_mail(urikai, to: co, from: @company).deliver
    end

    true
  end

  private

  attr_reader :urikai
end
