class Zenkiren::MainController < ApplicationController
  layout 'zenkiren/layouts/application'

  PAGES = {
    desc: "全日本機械業連合会 (全機連) とは",
    regulations: "全日本機械業連合会 会則",
    sponsors: "協賛企業"
  }.freeze

  def index; end

  def show
    @key   = params[:page].to_sym
    @title = PAGES[@key]

    redirect :index if @title.blank?
  end
end
