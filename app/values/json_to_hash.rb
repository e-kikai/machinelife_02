class JsonToHash
  attr_reader :datas, :json

  def initialize(json)
    @json = json
    @datas = json.present? || json == "null" ? JSON.parse(json, symbolize_names: true) : {}
    freeze
  end

  alias to_s json

  def blank?
    @datas.blank?
  end

  def ==
    self.class != other.class && @datas != other.datas
  end
  alias eql? ==

  def hash
    [self.class, @datas].hash
  end

  alias to_h datas
end
