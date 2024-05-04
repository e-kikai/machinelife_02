class Daihou::MachinesController < Daihou::ApplicationController
  def index
    @machines = @company.machines.sales

    ### フィルタリング ###
    @filtering_genres = @machines.group("machines.genre_id", "genres.genre").order(count: :desc, genre_id: :asc).limit(100).count
    @filtering_makers = @machines.where.not(maker2: "").group("COALESCE(makers.maker_master, machines.maker2)").order(count: :desc).limit(100).count

    ### 検索 ###
    @machines = @machines.where(genre_id: params[:g]) if params[:g].present?
    @machines = @machines.where(maker: params[:ma]) if params[:ma].present?

    ### ソート ###
    @machines = @machines.order(Arel.sql("CAST(REGEXP_REPLACE(machines.no, '[^0-9]', '', 'g') as INTEGER)"))
  end

  def show
    @machine = @company.machines.find(params[:id])

    @show_contact = false
  end
end
