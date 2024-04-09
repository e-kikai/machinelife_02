class Admin::SessionsController < Admin::ApplicationController
  skip_before_action :auth

  def new
    @login_form = Admin::LoginForm.new
  end

  def create
    @login_form = Admin::LoginForm.new(login_params)

    if user = @login_form.save # 認証
      session[:user_id]    = user[:id]         # ログイン処理
      session[:company_id] = user[:company_id] # 代理ログイン用に会社IDを別に格納

      case user&.role
      when "system"; redirect_to "/system/", notice: "管理者ログインしました。"
      when "member"; redirect_to "/admin/",  notice: "会員ログインしました。"
      else;          redirect_to "/",        notice: "ログインしました。"
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id) # ログアウト処理

    redirect_to "/", status: :see_other, notice: "会員ページからログアウトしました。"
  end

  private

  def login_params
    params.require(:admin_login_form).permit(:account, :passwd)
  end
end
