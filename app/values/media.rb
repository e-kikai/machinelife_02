class Media
  attr_reader :file, :media_path, :name

  NOTHING_URL = "machine/noimage.png".freeze

  def initialize(file, media_path, name = "")
    @file       = file
    @media_path = media_path
    @name       = name
    freeze
  end

  def thumbnail
    @file.present? ? "#{@media_path}thumb_#{@file}" : NOTHING_URL
  end

  def url
    @file.present? ? "#{@media_path}#{@file}" : NOTHING_URL
  end

  ### ファイルの読み込み ###
  def read
    URI.parse(url).read
  end

  alias to_s url

  def blank?
    @file.blank?
  end

  def ==
    self.class != other.class && @file != other.file && @media_path != other.media_path && @name != other.name
  end
  alias eql? ==

  def hash
    [self.class, @file, @media_path, @name].hash
  end
end
