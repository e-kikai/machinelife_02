class System::UsersController < System::ApplicationController
  include Exports

  before_action :set_user, only: %w[edit update destroy]

  def index
    @users = User.includes(:company).where(deleted_at: nil).order(:id)

    respond_to do |format|
      format.html
      format.csv { export_csv "users.csv" }
    end
  end

  def new
    @user_form = System::UserForm.new
  end

  def edit
    @user_form = System::UserForm.new(user: @user)
  end

  def create
    @user_form = System::UserForm.new(user_params)

    if @user_form.save
      redirect_to "/system/users", notice: "ユーザ情報を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @user_form = System::UserForm.new(user_params, user: @user)

    if @user_form.save
      redirect_to "/system/users", notice: "ユーザ情報を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.soft_delete

    redirect_to "/system/users", status: :see_other, notice: "#{@user.id}\ : #{@user.user_name} のユーザ情報を削除しました。"
  end

  private

  def set_user
    @user = User.where(deleted_at: nil).find(params[:id])
  end

  def user_params
    params.require(:system_user_form).permit(:user_name, :company_id, :role, :account, :passwd)
  end
end
