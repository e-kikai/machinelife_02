class Daihou::ContactsController < Daihou::ApplicationController
  before_action :set_targets, only: %i[new create]
  before_action :set_contact_visibility, only: %i[new show]

  def index; end

  def new
    @contact_form = Daihou::ContactForm.new(contact: @company.contacts.new, targets: @targets)
  end

  def create
    @contact_form = Daihou::ContactForm.new(contact_params, contact: @company.contacts.new, targets: @targets)

    if verify_recaptcha(model: @contact_form) && @contact_form.save
      redirect_to "/contact", notice: "お問い合せは送信されました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:daihou_contact_form).permit(:user_name, :user_company, :mail, :tel, :addr1, :message, :fax, r: [])
  end

  def set_targets
    @title, @targets =
      if params[:m].present?
        ["在庫機械への問い合わせ", Machine.where(deleted_at: nil, id: params[:m])]
      else
        ["大宝機械への問い合わせ", nil]
      end
  end

  def set_contact_visibility
    @show_contact = false
  end
end
