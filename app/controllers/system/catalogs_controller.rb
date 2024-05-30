class System::CatalogsController < System::ApplicationController
  def csv
    @catalog_csv_form = System::CatalogCsvForm.new
  end

  def csv_upload
    @catalog_csv_form = System::CatalogCsvForm.new(catalog_csv_params)

    @catalog_csv_form.upload

    redirect_to "/system/catalogs/csv", alert: 'カタログ情報がありませんでした2' if @catalog_csv_form.catalogs.empty?

    session[:system_catalog_csv_form_attributes] = { catalogs: @catalog_csv_form.catalogs }

    redirect_to "/system/catalogs/csv_confirm"
  end

  def csv_confirm
    @genre_list = Genre.pluck(:id, :genre).to_h
    @catalog_csv_form = System::CatalogCsvForm.new(session[:system_catalog_csv_form_attributes])

    redirect_to "/system/catalogs/csv", alert: 'カタログ情報がありませんでした3' if @catalog_csv_form.catalogs.empty?
  end

  def csv_import
    @catalog_csv_form = System::CatalogCsvForm.new(session[:system_catalog_csv_form_attributes])

    if @catalog_csv_form.save
      redirect_to "/system/", notice: "カタログ登録が完了しました。"
    else
      render :csv, status: :unprocessable_entity
    end
  end

  def sftp; end

  private

  def catalog_csv_params
    params.require(:system_catalog_csv_form).permit(:csv_file)
  end
end
