module Hosts
  extend ActiveSupport::Concern

  require 'resolv'

  def ip
    request.env["HTTP_X_FORWARDED_FOR"].split(",").first.strip || request.remote_ip
  end

  def host
    session[:host] ||=
      begin
        Resolv.getname(ip)
      rescue StandardError
        ""
      end
  end

  def logging?
    browser = Browser.new(request.user_agent)

    !browser.bot? && !(Rails.env.production? && system_user?)
  end

  def log_data(datas = {})
    {
      user_id: current_user_id,
      r: params[:r] || "",
      ip:,
      host:,
      referer: request.referer,
      ua: request.user_agent,
      utag: session[:utag]
    }.merge(datas)
  end
end
