class System::MailForm < FormBase
  attribute :file
  attribute :subject, :string
  attribute :message, :string
  # attribute :target, :string
  attribute :send_count, :integer
  attribute :val, :string
  attribute :val_label, :string

  delegate :id, :persisted?, to: :mail

  ### validater ###
  validates_presence_of %i[subject message val]

  SLICE_ATTRS = %i[subject message val].freeze
  TEST_MAILS = [["テスト送信(確認用)", "info@zenkiren.net"]].freeze

  def initialize(attributes = nil, mail: SystemMail.new)
    @mail = mail
    super(attributes)
  end

  def persist
    # メール送信先取得
    mails = val_mails(val)

    # ログ格納
    val_label = (vals.to_h { |ta| [ta[1].to_s, ta[0]] })[val.to_s]
    filename = file.original_filename if file.present?

    mail.assign_attributes(
      slice(SLICE_ATTRS).merge({ send_count: mails.length, val_label:, file: filename })
    )

    # メール送信
    mails.each do |ma|
      SystemMailMailer.group_mail(ma[1], ma[0], mail, file).deliver
    end

    # ログ保存
    mail.save!
  end

  def vals
    groups = Group.order(:parent_id, :id).pluck(:groupname, :id)
    ranks = Company::RANKS_JA.invert.to_a

    [
      ["テスト送信", :test],
      ["すべての全機連メンバー", :all]
    ].concat(groups).concat(ranks).push(["ワーキンググループ", :workinggroup])
  end

  def val_counts
    set_companies

    all_count     = @companies.count
    group_counts  = @companies.group(:group_id).count
    parent_counts = @companies.joins(:group).group("groups.parent_id").count
    rank_counts   = @companies.group(:rank).count

    {
      test: TEST_MAILS.count,
      all: all_count,
      workinggroup: workinggroups.count
    }.merge(group_counts).merge(parent_counts).merge(rank_counts).symbolize_keys
  end

  # 送信先選択肢
  def select_vals
    vals.map { |ta| ["#{ta[0]} (#{val_counts[ta[1]]})", ta[1]] }
  end

  def val_mails(val)
    set_companies

    case val.to_sym
    when :test; []
    when :all; @companies.pluck(:company, :mail)
    when :workinggroup; workinggroups
    when ->(v) { Company.ranks.symbolize_keys.key?(v) }; @companies.where(rank: val).pluck(:company, :mail)
    else @companies.joins(:group).merge(Company.where("groups.parent_id" => val).or(Company.where(group_id: val))).pluck(:company, :mail)
    end.concat(TEST_MAILS)
  end

  private

  attr_reader :mail

  def default_attributes
    mail.slice(SLICE_ATTRS)
  end

  def set_companies
    ignores = File.read(SystemMail::IGNORES_FILE_PATH, encoding: 'sjis').strip.split("\n")

    @companies = Company.where.not(mail: nil).where.not(mail: ignores)
  end

  def workinggroups
    CSV.read(SystemMail::WORKINGGROUPS_FILE_PATH, headers: true, encoding: 'sjis').map { |co| ["#{co[0]} #{co[1]}", co[2]] }
  end
end
