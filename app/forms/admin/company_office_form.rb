class Admin::CompanyOfficeForm < FormBase
  attribute :name, :string
  attribute :zip, :string
  attribute :addr1, :string
  attribute :addr2, :string
  attribute :addr3, :string

  SLICE_ATTRS = %i[name zip addr1 addr2 addr3].freeze

  def initialize(attributes = nil, company_office: {})
    @company_office = company_office
    super(attributes)
  end

  def persist
    company.update!(slice(SLICE_ATTRS).merge({ changed_at: Time.current }))
  end

  private

  attr_reader :company_office

  def default_attributes
    company_office.slice(*SLICE_ATTRS)
  end
end
