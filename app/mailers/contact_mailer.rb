class ContactMailer < ApplicationMailer
  ### 機械 ###
  def contact_machine(contact, machine)
    @contact = contact
    @machine = machine

    mail(
      to: @machine.company.contact_mail,
      reply_to: @contact.mail,
      subject: "マシンライフ: 在庫機械についての問い合わせ通知"
    )
  end

  ### 会社 ###
  def contact_company(contact, company)
    @contact = contact
    @company = company

    mail(
      to: @company.contact_mail,
      reply_to: @contact.mail,
      subject: "マシンライフ: 会社についての問い合わせ通知"
    )
  end

  ### 事務局 ###
  def contact_system(contact)
    @contact = contact

    mail(
      to: "inof@zenkiren.net",
      reply_to: @contact.mail,
      subject: "マシンライフ: 問い合わせ通知"
    )
  end

  ### ユーザへ送信確認 ###
  def contact_confirm(contact, targets)
    @contact = contact
    @targets = targets

    mail(
      to: @contact.mail,
      reply_to: "inof@zenkiren.net",
      subject: "マシンライフ:お問い合せ送信確認"
    )
  end
end
