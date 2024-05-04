class Admin::DInfoForm < FormBase
  attribute :info_date, :string
  attribute :title, :string
  attribute :contents, :string

  delegate :id, :persisted?, to: :d_info

  ### validater ###
  validates_presence_of %i[info_date title contents]

  SLICE_ATTRS = %i[info_date title contents].freeze

  def initialize(attributes = nil, d_info:)
    @d_info = d_info
    super(attributes)
  end

  def persist
    d_info.update!(slice(SLICE_ATTRS).merge({ changed_at: Time.current }))
  end

  private

  attr_reader :d_info

  def default_attributes
    d_info.slice(SLICE_ATTRS)
  end
end
