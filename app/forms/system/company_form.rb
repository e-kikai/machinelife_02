class System::CompanyForm < FormBase
  attribute :company_name,   :string
  attribute :company_kana,   :string
  attribute :representative, :string
  attribute :zip,            :string
  attribute :addr1,          :string
  attribute :addr2,          :string
  attribute :addr3,          :string
  attribute :tel,            :string
  attribute :fax,            :string
  attribute :mail,           :string
  attribute :website,        :string
  attribute :group_id,       :integer
  attribute :rank,           :string

  delegate :id, :persisted?, to: :company

  SLICE_ATTRS = %i[company_kana representative zip addr1 addr2 addr3 tel fax mail website group_id rank].freeze

  ### validater ###
  validates_presence_of %i[company_name company_kana representative zip addr1 addr2 addr3 tel group_id rank]

  def initialize(attributes = nil, company: Company.new)
    @company = company
    super(attributes)
  end

  def persist
    company.update(slice(SLICE_ATTRS).merge({ company: company_name, changed_at: Time.current }))

    ### お知らせ配信 ###
    mailchimp = Mailchimp.new(:admin)
    mailchimp.set_list_member(
      mail,
      {
        COMPANY: company_name,
        COMPANY_K: company_name,
        REP: representative,
        ADDR1: addr1,
        GROUP1: @company.parent&.groupname,
        GROUP2: @company.group.groupname,
        RANK: @company.rank_ja,
        NUM: @company.machines.count,
        ID: @company.id
      }
    )

    true
  end

  # グループ選択肢
  def select_groups
    Group.order(:parent_id, :id)
  end

  # ランク選択肢
  def select_ranks
    Company::RANKS_JA.invert
  end

  private

  attr_reader :company

  def default_attributes
    company.slice(SLICE_ATTRS).merge(company_name: company.company)
  end
end
