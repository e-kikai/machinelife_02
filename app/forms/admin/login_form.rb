class Admin::LoginForm < FormBase
  attribute :account, :string
  attribute :passwd, :string

  attr_reader :user

  ### validater ###
  validates_presence_of :account, :passwd

  def initialize(attributes = nil)
    super(attributes)
  end

  def persist
    user = User.find_by(account:, passwd:)

    errors.add(:base, "ログインに失敗しました。\nメールアドレスもしくはパスワードが違っています。") unless user

    user
  end
end
