class System::UserForm < FormBase
  attribute :user_name,  :string
  attribute :company_id, :integer
  attribute :role,       :string
  attribute :account,    :string
  attribute :passwd,     :string

  delegate :id, :persisted?, to: :user

  ### validater ###
  validates_presence_of %i[user_name role account]
  validate :check_passwd_only_new

  SLICE_ATTRS = %i[user_name company_id role account].freeze

  def initialize(attributes = nil, user: User.new)
    @user = user
    super(attributes)
  end

  def persist
    user.attributes = slice(SLICE_ATTRS).merge({ changed_at: Time.current })
    user.assign_attributes(passwd:, passwd_changed_at: Time.current) if passwd.present? # パスワード登録・変更

    user.save!
  end

  # 会社用選択肢
  def select_companies
    Group.includes(:companies).where(companies: { deleted_at: nil }).order(:parent_id, :id, "companies.id")
  end

  private

  attr_reader :user

  def default_attributes
    user.slice(SLICE_ATTRS)
  end

  # 新規作成の場合、パスワードを必須に
  def check_passwd_only_new
    errors.add(:mail, 'パスワードがありません。') if user.new_record? && passwd.blank?
  end
end
