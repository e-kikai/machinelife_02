class Admin::CatalogRequestForm < FormBase
  attribute :maker, :string
  attribute :model, :string
  attribute :comment, :string

  delegate :id, :persisted?, to: :catalog_request

  ### validater ###
  validates_presence_of %i[maker model]

  SLICE_ATTRS = %w[maker model comment].freeze

  def initialize(attributes = nil, catalog_request: CatalogRequest.new, user: nil)
    @catalog_request = catalog_request
    @user = user
    super(attributes)
  end

  def persist
    # メール送信先一覧
    companies = Company.where.not(mail: nil).where.not(id: @user.company&.id)

    # 格納
    catalog_request.assign_attributes(
      slice(SLICE_ATTRS).merge({ target: :catalog, user: @user, send_count: companies.length })
    )

    # メール送信
    companies.each do |co|
      CatalogRequestMailer.request_mail(catalog_request, to: co, from: @user.company).deliver
    end

    # リクエストログ保存
    catalog_request.save!

    true
  end

  private

  attr_reader :catalog_request
end
