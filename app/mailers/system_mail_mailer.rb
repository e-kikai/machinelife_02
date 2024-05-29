class SystemMailMailer < ApplicationMailer
  ### 機械 ###
  def group_mail(mail, name, system_mail, tmp_file = nil)
    @mail = mail
    @name = name
    @system_mail = system_mail

    # 添付ファイル処理
    attachments[tmp_file.original_filename] = File.read(tmp_file.path) if tmp_file.present?

    mail(
      to: @mail,
      reply_to: "inof@zenkiren.net",
      subject: "マシンライフ : #{@system_mail.subject}"
    )
  end
end
