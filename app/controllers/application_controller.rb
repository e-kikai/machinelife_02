class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :make_utag

  ### IPアドレス取得処理 ###
  def ip
    request.env["HTTP_X_FORWARDED_FOR"].split(",").first.strip || request.remote_ip
  end

  ### 未ログインユーザ追跡タグ生成 ###
  def make_utag
    session[:utag] = SecureRandom.alphanumeric(10) if session[:utag].blank?
  end

  ### ログインユーザ情報取得 ###
  def user_signed_in
    session[:user_id].present?
  end

  def current_user_id
    session[:user_id] || nil
  end

  def current_user
    User.find_by(id: current_user_id)
  end

  def current_company_id
    session[:company_id] || nil
  end

  def current_company
    current_company_id.present? ? Company.find(current_company_id) : nil
  end

  def system_user?
    current_user&.role == "system"
  end
end
