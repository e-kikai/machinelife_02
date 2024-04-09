class System::ApplicationController < ApplicationController
  before_action :auth

  def auth
    if current_user_id.blank?
      redirect_to "/admin/login", alert: "ログインしていません。"
    elsif current_user&.role != "system"
      redirect_to "/admin/login", alert: "管理者ログインしていません。"
    end
  end
end
