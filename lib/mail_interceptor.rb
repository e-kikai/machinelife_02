class MailInterceptor
  def self.delivering_email(message)
    message.to      = "bata44883@gmail.com"
    message.subject = "[Test] #{message.subject}"
  end
end
