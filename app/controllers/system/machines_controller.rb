class System::MachinesController < System::ApplicationController
  def csv
    @used_csv_form = System::UsedCsvForm.new
  end

  def csv_upload
    @used_csv_form = System::UsedCsvForm.new(used_csv_params)

    @used_csv_form.upload

    redirect_to "/system/machines/csv", alert: '在庫機械情報がありませんでした2' if @used_csv_form.machines.empty?

    session[:system_used_csv_form_attributes] =
      {
        company_id: @used_csv_form.company_id,
        machines: @used_csv_form.machines,
        used_company_id: @used_csv_form.used_company_id
      }

    redirect_to "/system/machines/csv_confirm"
  end

  def csv_confirm
    @genre_list = Genre.pluck(:id, :genre).to_h
    @used_csv_form = System::UsedCsvForm.new(session[:system_used_csv_form_attributes])

    redirect_to "/system/machines/csv", alert: '出品会社を選択してください' if session[:system_used_csv_form_attributes][:company_id].blank?

    @company = Company.find(session[:system_used_csv_form_attributes][:company_id])
    @current_machine_count = @company.machines.where.not(used_id: nil).count

    redirect_to "/system/machines/csv", alert: '在庫機械情報がありませんでした3' if @used_csv_form.machines.empty?
  end

  def csv_import
    @used_csv_form = System::UsedCsvForm.new(session[:system_used_csv_form_attributes])

    if @used_csv_form.save
      redirect_to "/system/", notice: "一括登録が完了しました。"
    else
      render :csv, status: :unprocessable_entity
    end
  end

  private

  def csv_machines_params
    params.require(:machines).map { |ma| ma.permit(:app_no, :name, :maker, :model, :year, :spec, :condition, :comment, :min_price, :genre_id, :youtube, :display, :hitoyama, :soft_destroyed_at) }
  end

  def used_csv_params
    params.require(:system_used_csv_form).permit(:company_id, :csv_file)
  end
end
