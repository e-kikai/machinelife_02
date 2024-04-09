class System::CatalogsController < System::ApplicationController
  def csv
    @csv_form = System::CatalogCsvForm.new
  end

  def csv_upload
    @csv_form = System::CatalogCsvForm.new(catalog_csv_params)

    @csv_form.upload

    redirect_to "/system/catalogs/csv", alert: @csv_form.errors.full_messages.join(", ") if @csv_form.errors.any?
  end

  def csv_import
    @csv_form = System::CatalogCsvForm.new(catalogs_params)

    num = csv_catalogs_params.length

    redirect_to "/system/catalogs/csv", alert: '一括登録するカタログがありません' if csv_catalogs_params.empty?

    Catalog.import(csv_products_params)
    redirect_to("/system/catalogs/", notice: "#{num}件のカタログを一括登録しました")
  end

  def catalog_csv_params
    params.require(:system_catalog_csv_form).permit(:csv_file)
  end

  def catalogs_params
    params.require(:system_catalog_csv_form)
      .map { |ca| ca.permit(:uid, :maker, :maker_kana, :year, :catalog_no, :models, genre_ids: []) }
  end
end
