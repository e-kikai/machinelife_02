require 'rails_helper'

RSpec.describe "System::Catalogs", type: :request do
  describe "GET /csv" do
    it "returns http success" do
      get "/system/catalogs/csv"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /csv_upload" do
    it "returns http success" do
      get "/system/catalogs/csv_upload"
      expect(response).to have_http_status(:success)
    end
  end

end
