class Admin::UrikaisController < Admin::ApplicationController
  before_action :set_urikai, only: [:show, :update]

  def index
    @urikais = Urikai.where(company: current_company).order(id: :desc)

    @pagy, @purikais = pagy(@urikais, limit: 50)
  end

  def show; end

  def new
    @urikai_form = Admin::UrikaiForm.new(company: current_company)
  end

  def create
    @urikai_form = Admin::UrikaiForm.new(urikai_params, company: current_company)

    if @urikai_form.save
      redirect_to "/admin/urikais", notice: "売りたし買いたしを保存・メール送信しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @urikai.update(end_date: Time.current, changed_at: Time.current)
      redirect_to "/admin/urikais", notice: "売り買い情報を解決済みにしました"
    else
      redirect_to "/admin/urikais", alert: "売り買い情報を解決済みできませんでした"
    end
  end

  private

  def set_urikai
    @urikai = Urikai.find(params[:id])
  end

  def urikai_params
    params.require(:admin_urikai_form).permit(:goal, :contents, :tel, :fax, :mail, images: [], images_delete: [], images_cancel: [])
  end
end
