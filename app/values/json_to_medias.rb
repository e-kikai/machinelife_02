class JsonToMedias
  attr_reader :datas, :json, :medias

  def initialize(json, media_path)
    @json       = json
    @media_path = media_path

    @datas = json.present? || json == "null" ? JSON.parse(json, symbolize_names: true) : {}

    @medias =
      if @datas.instance_of?(Hash)
        @datas.map do |key, value|
          Media.new(value, @media_path, key)
        end
      else
        @datas.map do |value|
          Media.new(value, @media_path)
        end
      end

    freeze
  end

  alias to_s json

  def blank?
    @parsed.blank?
  end

  def ==
    self.class != other.class && @datas != other.datas
  end
  alias eql? ==

  def hash
    [self.class, @datas].hash
  end

  alias to_h medias
end
