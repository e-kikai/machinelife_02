class System::MachinesController < System::ApplicationController
  before_action :set_company, only: %i[csv_upload csv_import]

  def csv
    @select_companies = Group.includes(:companies).order(:parent_id, :id, "companies.id")
  end

  def csv_upload
    redirect_to "/system/machines/csv", alert: 'CSVファイルを選択してください' if params[:file].blank?

    @res = @company.machine.import_conf(params[:file])
    redirect_to "/system/machines/csv", alert: '在庫機械情報がありませんでした' if @res.empty?
  end

  def csv_import
    num = csv_machines_params.length

    redirect_to "/system/machines/csv", alert: '一括登録する在庫機械がありません' if num.zero?

    @company.machine.import(csv_products_params)
    redirect_to("/system/machines/", notice: "#{num}件の在庫機械を一括登録しました")
  end

  def csv_machines_params
    params.require(:machines).map { |ma| ma.permit(:app_no, :name, :maker, :model, :year, :spec, :condition, :comment, :min_price, :genre_id, :youtube, :display, :hitoyama, :soft_destroyed_at) }
  end

  private

  def set_company
    redirect_to "/system/machines/csv", alert: '出品会社を選択してください' if params[:company_id].blank?

    @company = Company.find(params[:company_id])
  end
end
