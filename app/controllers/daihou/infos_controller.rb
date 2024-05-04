class Daihou::InfosController < Daihou::ApplicationController
  def index
    @d_infos = @company.d_infos.order(info_date: :desc)
  end

  def show
    @d_info = @company.d_infos.find(params[:id])
    @d_infos = @company.d_infos.order(info_date: :desc).limit(20)
  end
end
