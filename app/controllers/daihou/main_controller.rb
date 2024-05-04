class Daihou::MainController < Daihou::ApplicationController
  def index
    @machines = @company.machines.order(id: :desc).limit(8)

    @d_infos = @company.d_infos.order(info_date: :desc).limit(5)
  end

  def access; end
end
