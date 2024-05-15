class CatalogsController < ApplicationController
  include Hosts

  def show
    catalog = Catalog.find(params[:id])
    disposition = params[:dl].present? ? :attachment : :inline

    # ロギング
    if logging? && params[:id] != session[:before_catalog_id]
      CatalogLog.create(log_data({ catalog_id: params[:id] }))

      session[:before_catalog_id] = params[:id]
    end

    respond_to do |format|
      format.pdf { send_data(catalog.file_media.read, filename: "catalog_#{catalog.file}", type: 'application/pdf', disposition:, stream: true) }
    end
  end
end
