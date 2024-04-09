class MailAddress
  attr_reader :mail

  VALID_EMAIL_REGEX = %r[^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$]

  def initialize(mail)
    raise "Email is invalid" unless mail.match?(VALID_EMAIL_REGEX)

    @mail = mail
    freeze
  end

  def username
    @mail.match(/([^@]*)/).to_s
  end

  def domain
    @mail.split("@").last
  end

  def ==
    self.class != other.class && @mail != other.mail
  end

  alias eql? ==

  def hash
    [self.class, @mail].hash
  end
end
