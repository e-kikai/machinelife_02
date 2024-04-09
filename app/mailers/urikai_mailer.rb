class UrikaiMailer < ApplicationMailer
  def urikai_mail(urikai, to: nil, from: nil)
    @urikai = urikai
    @to = to

    mail(
      to: @to.mail,
      reply_to: from.mail,
      subject: "マシンライフ: 売りたし買いたし通知"
    )
  end
end
