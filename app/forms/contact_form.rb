class ContactForm < FormBase
  PRESETS =
    %w[
      この機械の状態を知りたい
      この機械の価格を知りたい
      送料を知りたい\ (↓に送付先住所を記入してください)
      現物を見たい
      試運転は可能ですか
    ].freeze

  RETURN_TYPES = %w[メールで連絡を希望 電話で連絡を希望 FAXで連絡を希望].freeze

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  attribute :id, :integer
  attribute :mail, :string
  attribute :mail_check_1, :string
  attribute :mail_check_2, :string
  attribute :user_company, :string
  attribute :user_name, :string
  attribute :tel, :string
  attribute :addr1, :string
  attribute :fax, :string
  attribute :mailuser_flag, :boolean
  attribute :other_message, :string
  attribute :r, default: []
  attribute :s, default: []

  attribute :message, :string
  attribute :return_time, :string

  delegate :id, :persisted?, to: :contact

  ### validater ###
  validates_presence_of %i[mail user_company message]
  validates :mail, format: { with: VALID_EMAIL_REGEX }
  validate :check_mail
  validate :check_message

  SLICE_ATTRS = %w[user_company user_name mail tel addr1 fax mailuser_flag].freeze

  def initialize(attributes = nil, contact: Contact.new, targets: nil)
    @contact = contact
    @targets = targets
    super(attributes)
  end

  def persist
    contact.assign_attributes(slice(SLICE_ATTRS).merge({ message:, return_time: }))

    target_labels = []

    if @targets&.klass == Machine # 機械問い合わせ
      @targets.each do |ma|
        ma_contact = contact.dup
        ma_contact.update!({ machine_id: ma.id, company_id: ma.company_id })

        # メール送信
        ContactMailer.contact_machine(ma_contact, ma).deliver
        target_labels << "#{ma.no} #{ma.maker} #{ma.no} #{ma.model} → #{ma.company.company}"
      end
    elsif @targets&.klass == Company # 出品会社問い合わせ
      @targets.each do |co|
        co_contact = contact.dup
        co_contact.update!({ company_id: co.id })

        # メール送信
        ContactMailer.contact_company(co_contact, co).deliver
        target_labels << co.company
      end
    else # 事務局問い合わせ
      contact.save!

      # メール送信
      ContactMailer.contact_system(contact).deliver
      target_labels << "全機連事務局"
    end

    ### 確認メール ###
    ContactMailer.contact_confirm(contact, target_labels).deliver

    ### お知らせ配信 ###
    if mailuser_flag
      mailchimp = Mailchimp.new
      mailchimp.set_list_member(mail, { NAME: user_name, COMPANY: user_company })
    end

    true
  end

  # 入力フォームデータの再利用
  def reuse
    slice(%i[user_company user_name mail tel fax addr1 r])
  end

  private

  attr_reader :contact

  ### メールアドレスの確認 ###
  def check_mail
    errors.add(:mail, "メールアドレスとメールアドレス(確認)が違っています。") if mail != "#{mail_check_1}@#{mail_check_2}"
  end

  def check_message
    errors.add(:other_message, "内容を選択及び入力してください。") if s.blank? && other_message.blank?
  end

  def attributes_format
    self.message = "#{s.join("\n")}\n\n#{other_message}".strip
    self.return_time = r.join("\n")
  end
end
