class System::MailsController < ApplicationController
  def index
    @mails = SystemMail.order(id: :desc)

    ### ページャ ###
    @pagy, @pmails = pagy(@mails, limit: 20)
  end

  def new
    @mail_form = System::MailForm.new
  end

  def create
    @mail_form = System::MailForm.new(mail_params)

    if @mail_form.save
      redirect_to "/system/mails", notice: "お知らせを登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def ignore
    @ignores = File.read(SystemMail::IGNORES_FILE_PATH, encoding: 'sjis')
  end

  def ignore_update
    File.write(SystemMail::IGNORES_FILE_PATH, params[:ignores].to_s.strip, encoding: 'sjis')

    redirect_to "/system/", notice: "非送信メールアドレス一覧を保存しました。"
  end

  private

  def mail_params
    params.require(:system_mail_form).permit(:subject, :message, :val, :file)
  end
end
