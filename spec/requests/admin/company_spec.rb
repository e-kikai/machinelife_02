require 'rails_helper'

RSpec.describe "Admin::Companies", type: :request do
  describe "GET /edit" do
    it "returns http success" do
      get "/admin/company/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/admin/company/update"
      expect(response).to have_http_status(:success)
    end
  end

end
