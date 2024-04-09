class System::BidinfoForm < FormBase
  attribute :bid_name, :string
  attribute :uri, :string
  attribute :organizer, :string
  attribute :place, :string
  attribute :preview_start_date, :date
  attribute :preview_end_date, :date
  attribute :bid_date, :datetime
  attribute :banner_image
  attribute :banner_image_delete, :boolean

  delegate :id, :persisted?, :banner_file_media, to: :bidinfo

  ### validater ###
  validates_presence_of %w[bid_name uri organizer place preview_start_date preview_end_date bid_date]

  SLICE_ATTRS = %w[bid_name uri organizer place preview_start_date preview_end_date bid_date].freeze

  def initialize(attributes = nil, bidinfo: Bidinfo.new)
    @bidinfo = bidinfo
    super(attributes)
  end

  def persist
    bidinfo.attributes = slice(SLICE_ATTRS).merge({ changed_at: Time.current })

    if banner_image.present?
      bidinfo.banner_image = banner_image
    elsif banner_image_delete == true
      bidinfo.banner_image = nil
    end

    bidinfo.save!
  end

  private

  attr_reader :bidinfo

  def default_attributes
    bidinfo.slice([:banner_image].concat(SLICE_ATTRS))
  end
end
