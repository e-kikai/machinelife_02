class Admin::ApplicationController < ApplicationController
  before_action :auth

  def auth
    if current_user_id.blank?
      redirect_to "/admin/login", alert: "ログインしていません。"
    elsif !current_user&.role.in? %w|system member|
      redirect_to "/admin/login", alert: "会員ログインしていません。"
    end
  end
end
