require 'rails_helper'

RSpec.describe "System::CatalogRequests", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/system/catalog_requests/index"
      expect(response).to have_http_status(:success)
    end
  end

end
