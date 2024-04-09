class Admin::PasswordForm < FormBase
  attribute :current_password, :string
  attribute :password, :string
  attribute :password_confirmation, :string

  delegate :id, :persisted?, to: :user

  ### validater ###
  validates_presence_of %i[current_password password password_confirmation]
  validate :check_password

  SLICE_ATTRS = %i[password].freeze

  def initialize(attributes = nil, user: User.new)
    @user = user
    super(attributes)
  end

  def persist
    user.update!(
      {
        passwd: password,
        passwd_changed_at: Time.current,
        changed_at: Time.current
      }
    )

    true
  end

  private

  attr_reader :user

  def check_password
    errors.add(:password, "現在のパスワードが違っています。") if user.passwd != current_password
    errors.add(:password, "新しいパスワードと確認用パスワードが違っています。") if password != password_confirmation
  end
end
