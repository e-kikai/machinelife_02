class Admin::MachinesController < Admin::ApplicationController
  before_action :check_rank
  before_action :set_machine, only: [:edit, :update]

  def index
    ### 検索・フィルタリング処理 ###
    @machines = current_company.machines.joins(:genre, :large_genre, :xl_genre).left_outer_joins(:maker_m)
      .then { |ms| params[:makers].present?     ? ms.where_maker(params[:makers])           : ms }
      .then { |ms| params[:genre_ids].present?  ? ms.where(genre_id: params[:genre_ids])    : ms }
      .then { |ms| params[:k].present?          ? ms.where_keyword(params[:k])                : ms }
      .then { |ms| params[:start_date].present? ? ms.where(created_at: params[:start_date]..) : ms }
      .then { |ms| params[:end_date].present?   ? ms.where(created_at: ..params[:end_date]) : ms }

    ### フィルタリング項目 ###
    @filtering_genres = @machines.group("machines.genre_id", "genres.genre").order(genre_id: :asc).limit(100).count.map { |k, v| ["#{k[1]} (#{v})", k[0]] }
    @filtering_makers = @machines.where.not(maker2: "").group("COALESCE(makers.maker_master, machines.maker2)").order(count: :desc).limit(100).count.map { |k, v| ["#{k} (#{v})", k] }

    ### ページャ ###
    @pagy, @pmachines = pagy(@machines.order_by_key(params[:sort]))

    @detail_logs_count = DetailLog.group(:machine_id).where(machine: @pmachines).count
  end

  def new
    machine = current_company.machines.build(genre_id: 1)

    @machine_form = Admin::MachineForm.new(machine:)
  end

  def edit
    @machine_form = Admin::MachineForm.new(machine: @machine)
  end

  def create
    @machine_form = Admin::MachineForm.new(machine_params, machine: current_company.machines.build)

    if @machine_form.save
      redirect_to "/admin/machines", notice: "在庫機械情報を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @machine_form = Admin::MachineForm.new(machine_params, machine: @machine)

    if @machine_form.save
      redirect_to "/admin/machines", notice: "在庫機械情報を登録しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def delete_all
    current_company.machines.where(id: params[:m]).soft_delete_all

    redirect_to "/admin/machines", status: :see_other, notice: "在庫機械を一括削除しました。"
  end

  def catalog_search
    @catalogs = params[:model].present? ? Catalog.includes(:genres).where_keyword(params[:model]) : []
  end

  def genre_specs
    @machine = params[:id].present? ? current_company.machines.find(params[:id]) : current_company.machines.build(genre_id: 1)
    @genre = params[:genre_id].present? ? Genre.find(params[:genre_id]) : Genre.new
  end

  private

  def set_machine
    @machine = current_company.machines.find(params[:id])
  end

  def machine_params
    params.require(:admin_machine_form)
      .permit(
        :no, :name, :maker, :model, :year, :spec, :accessory, :comment,
        :location, :addr1, :addr2, :addr3, :catalog_id, :genre_id,
        :commission, :price, :price_tax, :youtube, :view_option,
        :top_image, :top_image_delete,
        images: [], imgs_delete: [], images_delete: [], images_cancel: [],
        pdfs: [], pdfs_filename: [], pdfs_name: [], pdfs_delete: [], pdfs_cancel: [],
        machine_pdfs: [:name, :deleted_at]
      ).tap do |wl|
        wl[:others]   = params[:others].permit! if params[:others].present?
        wl[:capacity] = params[:capacity]
      end
  end

  def check_rank
    redirect_to "/admin", alert: "在庫管理の表示権限がありません" unless current_company&.check_rank(:a_member)
  end
end
