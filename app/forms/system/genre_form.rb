class System::GenreForm < FormBase
  attribute :genre_name, :string
  attribute :genre_kana, :string
  attribute :capacity_label, :string
  attribute :capacity_unit, :string
  attribute :order_no, :integer
  attribute :spec_labels, :string

  delegate :id, :persisted?, :xl_genre, :large_genre, to: :genre

  ### validater ###
  validates_presence_of %w[genre_name order_no]

  SLICE_ATTRS = %w[genre_kana capacity_label capacity_unit order_no spec_labels].freeze

  def initialize(attributes = nil, genre: Genre.new)
    @genre = genre
    super(attributes)
  end

  def persist
    genre.attributes = slice(SLICE_ATTRS).merge({ genre: genre_name, changed_at: Time.current })
    genre.save!
  end

  private

  attr_reader :genre

  def default_attributes
    genre.slice(SLICE_ATTRS).merge(genre_name: genre.genre)
  end
end
