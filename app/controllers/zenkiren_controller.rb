class ZenkirenController < ApplicationController
  PAGES = {
    desc: "全日本機械業連合会 (全機連) とは",
  }.freeze

  def index; end

  def show
    @key   = params[:id].to_sym
    @title = PAGES[@key]

    redirect :index if @title.blank?
  end
end
