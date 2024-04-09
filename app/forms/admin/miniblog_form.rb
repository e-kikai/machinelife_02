class Admin::MiniblogForm < FormBase
  attribute :target, :string
  attribute :contents, :string

  delegate :id, :persisted?, to: :miniblog

  ### validater ###
  validates_presence_of %i[target contents]

  SLICE_ATTRS = %w[target contents].freeze

  def initialize(attributes = nil, miniblog: Miniblog.new, user: nil)
    @miniblog = miniblog
    @user = user
    super(attributes)
  end

  def persist
    miniblog.update!(slice(SLICE_ATTRS).merge({ user: @user }))

    true
  end

  private

  attr_reader :miniblog
end
