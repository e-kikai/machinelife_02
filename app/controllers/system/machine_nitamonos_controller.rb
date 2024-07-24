class System::MachineNitamonosController < ApplicationController
  include Exports

  def new
    # @machines = Machine.includes(:machine_nitamonos)
    #   .merge(Machine.where.not(top_image: nil).or(Machine.where.not(top_img: nil)))
    #   .order(id: :desc)
    @machines = Machine.merge(Machine.where.not(top_image: nil).or(Machine.where.not(top_img: nil))).order(id: :desc)

    respond_to do |format|
      format.html
      format.csv { export_csv "machines_new_top_imgs.csv" }
    end
  end

  def create
    temp = []
    params[:_json].each do |ma|
      temp << [machine_id: ma[0], nitamono_id: ma[1], norm: ma[2]] << [machine_id: ma[1], nitamono_id: ma[0], norm: ma[2]]
    end

    MachineNitamono.insert_all(temp, record_timestamps: true)
  end
end
