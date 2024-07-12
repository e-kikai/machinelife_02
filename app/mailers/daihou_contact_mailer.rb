class DaihouContactMailer < ApplicationMailer
  ### 機械 ###
  def contact_machine(contact, machine)
    @contact = contact
    @machine = machine

    mail(
      to: @contact.company.contact_mail,
      reply_to: @contact.mail,
      subject: "#{@contact.company.company}ウェブサイト: 在庫機械についての問い合わせ通知"
    )
  end

  ### 会社 ###
  def contact_company(contact)
    @contact = contact

    mail(
      to: contact.company.contact_mail,
      reply_to: @contact.mail,
      subject: "#{@contact.company.company}ウェブサイト: 問い合わせ通知"
    )
  end

  ### ユーザへ送信確認 ###
  def contact_confirm(contact, targets)
    @contact = contact
    @targets = targets

    mail(
      to: @contact.mail,
      reply_to: contact.company.contact_mail,
      subject: "#{@contact.company.company}ウェブサイト :お問い合せ送信確認"
    )
  end
end
