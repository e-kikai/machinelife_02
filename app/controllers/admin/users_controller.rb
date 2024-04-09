class Admin::UsersController < ApplicationController
  def edit
    @password_form = Admin::PasswordForm.new(user: current_user)
  end

  def update
    @password_form = Admin::PasswordForm.new(password_params, user: current_user)

    if @password_form.save
      redirect_to "/admin/", notice: "パスワードを登録しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:admin_password_form).permit(:current_password, :password, :password_confirmation)
  end
end
