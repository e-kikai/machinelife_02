class ApplicationMailer < ActionMailer::Base
  # add_template_helper(ApplicationHelper)

  default from: "マシンライフ<info@zenkiren.net>"
  # layout "mailer"
end

ActionMailer::Base.register_observer(EmailLogObserver.new)
