class System::CatalogRequestsController < System::ApplicationController
  def index
    @catalog_requests = CatalogRequest.includes(:user, :company).order(request_id: :desc)

    @pagy, @pcatalog_requests = pagy(@catalog_requests, limit: 50)
  end
end
