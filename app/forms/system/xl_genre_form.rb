class System::XlGenreForm < FormBase
  attribute :xl_genre_name, :string
  attribute :xl_genre_kana, :string
  attribute :icon, :string
  attribute :order_no, :integer

  delegate :id, :persisted?, to: :xl_genre

  ### validater ###
  validates_presence_of %w[xl_genre_name order_no]

  SLICE_ATTRS = %w[xl_genre_kana icon order_no].freeze

  def initialize(attributes = nil, xl_genre: XlGenre.new)
    @xl_genre = xl_genre
    super(attributes)
  end

  def persist
    xl_genre.attributes = slice(SLICE_ATTRS).merge({ xl_genre: xl_genre_name, changed_at: Time.current })
    xl_genre.save!
  end

  private

  attr_reader :xl_genre

  def default_attributes
    xl_genre.slice(SLICE_ATTRS).merge(xl_genre_name: xl_genre.xl_genre)
  end
end
