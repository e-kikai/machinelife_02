class System::CompanyPdfForm < FormBase
  attribute :date, :string

  # delegate :id, :persisted?, to: :company

  ### validater ###
  validates_presence_of :date

  def initialize(attributes = nil, company: Company.new)
    @company = company
    super(attributes)
  end

  def persist
    company.attributes = {
      company_kana:, representative:, zip:, addr1:, addr2:, addr3:, tel:, fax:, mail:, website:, group_id:, rank:,
      company: company_name, changed_at: Time.current
    }

    company.save!
  end

  # グループ選択肢
  def select_groups
    Group.order(:parent_id, :id)
  end

  private

  attr_reader :company

  def default_attributes
    company.attributes.symbolize_keys
      .slice(:company_kana, :representative, :zip, :addr1, :addr2, :addr3, :tel, :fax, :mail, :website, :group_id, :rank)
      .merge(company_name: company.company)
  end
end
