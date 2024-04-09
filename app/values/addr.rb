class Addr
  attr_reader :addr1, :addr2, :addr3

  def initialize(addr1 = "", addr2 = "", addr3 = "")
    @addr1 = addr1
    @addr2 = addr2
    @addr3 = addr3
    freeze
  end

  def to_s
    "#{addr1} #{addr2} #{addr3}"
  end

  def ==
    self.class == other.class && @addr1 == other.addr1 && @addr2 == other.addr2 && @addr3 == other.addr3
  end
  alias eql? ==

  def hash
    [self.class, @addr1, @addr2, @addr3].hash
  end
end
