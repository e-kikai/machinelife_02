class System::CatalogsController < System::ApplicationController
  def csv
    @catalog_csv_form = System::CatalogCsvForm.new
  end

  def csv_upload
    @catalog_csv_form = System::CatalogCsvForm.new(catalog_csv_params)

    @catalog_csv_form.upload

    redirect_to "/system/catalogs/csv", alert: @csv_form.errors.full_messages.join(", ") if @csv_form.errors.any?

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
    @catalog_csv_form = System::UsedCsvForm.new(session[:system_used_csv_form_attributes])

    redirect_to "/system/machines/csv", alert: '在庫機械情報がありませんでした3' if @used_csv_form.machines.empty?
  end

  def csv_import
    @catalog_csv_form = System::CatalogCsvForm.new(catalogs_params)

    num = csv_catalogs_params.length

    redirect_to "/system/catalogs/csv", alert: '一括登録するカタログがありません' if csv_catalogs_params.empty?

    Catalog.import(csv_products_params)
    redirect_to("/system/catalogs/", notice: "#{num}件のカタログを一括登録しました")
  end

  private

  def catalog_csv_params
    params.require(:system_catalog_csv_form).permit(:csv_file)
  end

  def catalogs_params
    params.require(:system_catalog_csv_form)
      .map { |ca| ca.permit(:uid, :maker, :maker_kana, :year, :catalog_no, :models, genre_ids: []) }
  end

  def sftp; end
end
