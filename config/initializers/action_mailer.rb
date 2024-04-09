require_relative '../../lib/mail_interceptor'

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.default_url_options = { host: 'www.zenkiren.net' }
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  address: Rails.application.credentials.mail[:address],
  port: 587,
  user_name: Rails.application.credentials.mail[:user_name],
  password: Rails.application.credentials.mail[:password],
  authentication: :plain,
  enable_starttls_auto: true
}

case Rails.env
when "staging"
  ActionMailer::Base.default_url_options = { host: '52.198.41.71' }
  ActionMailer::Base.register_interceptor(MailInterceptor) # 自分宛てに転送
when "development"
  ActionMailer::Base.default_url_options = { host: 'localhost', port: 3000 }
  # ActionMailer::Base.register_interceptor(MailInterceptor) # 自分宛てに転送

  ActionMailer::Base.delivery_method = :letter_opener_web
end
