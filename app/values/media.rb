class Media
  attr_reader :file, :media_path, :name

  NOTHING_URL = "machine/noimage_02.png".freeze
  DAIHOU_NOTHING_URL = "daihou/daihou_noimg.png".freeze

  def initialize(file, media_path, name = "")
    @file       = file
    @media_path = media_path
    @name       = name
    freeze
  end

  def thumbnail(noimage: NOTHING_URL)
    @file.present? ? "#{@media_path}thumb_#{@file}" : noimage
  end

  def url(noimage: NOTHING_URL)
    @file.present? ? "#{@media_path}#{@file}" : noimage
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
