class System::InfoForm < FormBase
  attribute :info_date, :string
  attribute :target,    :string
  attribute :group_id,  :integer
  attribute :contents,  :string

  delegate :id, :persisted?, to: :info

  ### validater ###
  validates_presence_of %i[info_date target contents]

  SLICE_ATTRS = %i[info_date target group_id contents].freeze

  def initialize(attributes = nil, info: Info.new)
    @info = info
    super(attributes)
  end

  def persist
    info.attributes = slice(SLICE_ATTRS).merge({ changed_at: Time.current })

    info.save!
  end

  # グループ選択肢
  def select_groups
    Group.order(:parent_id, :id)
  end

  private

  attr_reader :info

  def default_attributes
    info.slice(SLICE_ATTRS)
  end
end
