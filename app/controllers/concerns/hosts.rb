module Hosts
  extend ActiveSupport::Concern

  require 'resolv'

  def ip
    request.env["HTTP_X_FORWARDED_FOR"].split(",").first.strip || request.remote_ip
  end

  def host
    if session[:host].nil?
      session[:host] =
        begin
          Resolv.getname(ip)
        rescue StandardError
          ""
        end
    end

    session[:host]
  end
end
