class Daihou::ContactForm < FormBase
  RETURN_TYPES = %w[メールで連絡を希望 電話で連絡を希望 FAXで連絡を希望].freeze

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  attribute :id, :integer
  attribute :mail, :string
  attribute :user_company, :string
  attribute :user_name, :string
  attribute :tel, :string
  attribute :addr1, :string
  attribute :fax, :string
  attribute :message, :string
  attribute :r, default: []
  attribute :return_time, :string

  delegate :id, :persisted?, to: :contact

  ### validater ###
  validates_presence_of %i[mail user_company message]
  validates :mail, format: { with: VALID_EMAIL_REGEX }

  SLICE_ATTRS = %w[user_company user_name mail tel addr1 fax].freeze

  def initialize(attributes = nil, contact: Contact.new, targets: nil)
    @contact = contact
    @targets = targets
    super(attributes)
  end

  def persist
    contact.assign_attributes(slice(SLICE_ATTRS).merge({ message: "<ウェブサイトからの問い合わせ>\n\n#{message}", return_time: }))

    target_labels = []

    if @targets&.klass == Machine # 機械問い合わせ
      @targets.each do |ma|
        ma_contact = contact.dup
        ma_contact.update!({ machine_id: ma.id })

        # メール送信
        DaihouContactMailer.contact_machine(ma_contact, ma).deliver
        target_labels << "#{ma.no} #{ma.maker} #{ma.no} #{ma.model} → #{ma.company.company}"
      end
    else # 会社(大宝機械)問い合わせ
      contact.save!

      # メール送信
      DaihouContactMailer.contact_company(contact).deliver
    end

    ### 確認メール ###
    DaihouContactMailer.contact_confirm(contact, target_labels).deliver

    true
  end

  # 入力フォームデータの再利用
  def reuse
    slice(%i[user_company user_name mail tel fax addr1 r])
  end

  private

  attr_reader :contact

  def attributes_format
    self.return_time = r.join("\n")
  end
end
