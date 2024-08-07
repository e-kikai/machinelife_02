class System::MachineNitamonosController < ApplicationController
  include Exports
  skip_before_action :verify_authenticity_token, only: [:create]

  def new
    # @machines = Machine.includes(:machine_nitamonos)
    #   .merge(Machine.where.not(top_image: nil).or(Machine.where.not(top_img: nil)))
    #   .order(id: :desc)
    # @machines = Machine.merge(Machine.where.not(top_image: nil).or(Machine.where.not(top_img: nil))).order(id: :desc)

    @machines = Machine.where.missing(:machine_nitamonos).where.not(top_image: nil).distinct.order(:id)
    @old_machines = Machine.where.associated(:machine_nitamonos).distinct.order(:id)

    respond_to do |format|
      format.html
      format.csv { export_csv "machines_new_top_imgs.csv" }
    end
  end

  def create
    temp = []
    params[:_json].each do |ma|
      temp << { machine_id: ma[0], nitamono_id: ma[1], norm: ma[2] }
      temp << { machine_id: ma[1], nitamono_id: ma[0], norm: ma[2] }
    end

    MachineNitamono.insert_all(temp, record_timestamps: true)
  end
end
