class ContactsController < ApplicationController
  before_action :set_targets, only: %i[new create]

  def new
    # デフォルト入力
    default_params = session[:contact_info]
    default_params[:other_message] = params[:mes]

    @contact_form = ContactForm.new(default_params, targets: @targets)
  end

  def create
    @contact_form = ContactForm.new(contact_params, targets: @targets)

    if verify_recaptcha(model: @contact_form) && @contact_form.save
      # 再利用用情報
      session[:contact_info] = @contact_form.reuse

      redirect_to "/contacts", notice: "お問い合せは送信されました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact_form)
      .permit(:user_name, :user_company, :mail, :mail_check_1, :mail_check_2, :tel, :addr1, :mailuser_flag, :other_message, :fax, s: [], r: [])
  end

  def set_targets
    @title, @targets =
      if params[:m].present?
        ["在庫機械への問い合わせ", Machine.includes(:company).where(deleted_at: nil, id: params[:m])]
      elsif params[:c].present?
        ["出品会社への問い合わせ", Company.where(deleted_at: nil, id: params[:c])]
      else
        ['全機連への問い合わせ', nil]
      end
  end
end
