class EmailLogObserver
  def delivered_email(email)
    msg = "from: #{email.from.join(',')} to: #{email.to.join(',')} subject: #{email.subject}"
    Rails.application.config.mail_logger.debug(msg)
  end
end
