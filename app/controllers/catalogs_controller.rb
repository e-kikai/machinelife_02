class CatalogsController < ApplicationController
  def show
    catalog = Catalog.find(params[:id])
    disposition = params[:dl].present? ? :attachment : :inline

    respond_to do |format|
      format.pdf { send_data(catalog.file_media.read, filename: "catalog_#{catalog.file}", type: 'application/pdf', disposition:, stream: true) }
    end
  end
end
