require 'rails_helper'

RSpec.describe "Admin::Catalogs", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/catalogs/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /search" do
    it "returns http success" do
      get "/admin/catalogs/search"
      expect(response).to have_http_status(:success)
    end
  end

end
