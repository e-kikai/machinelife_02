class System::LargeGenreForm < FormBase
  attribute :large_genre_name, :string
  attribute :large_genre_kana, :string
  attribute :order_no, :integer
  attribute :icon, :string

  delegate :id, :persisted?, :xl_genre, to: :large_genre

  ### validater ###
  validates_presence_of %w[large_genre_name order_no]

  SLICE_ATTRS = %w[large_genre_kana icon order_no].freeze

  def initialize(attributes = nil, large_genre: LargeGenre.new)
    @large_genre = large_genre
    super(attributes)
  end

  def persist
    large_genre.attributes = slice(SLICE_ATTRS).merge({ large_genre: large_genre_name, changed_at: Time.current })
    large_genre.save!
  end

  private

  attr_reader :large_genre

  def default_attributes
    large_genre.slice(SLICE_ATTRS).merge(large_genre_name: large_genre.large_genre)
  end
end
