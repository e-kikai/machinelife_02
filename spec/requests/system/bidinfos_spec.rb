require 'rails_helper'

RSpec.describe "System::Bidinfos", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/system/bidinfos/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/system/bidinfos/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/system/bidinfos/edit"
      expect(response).to have_http_status(:success)
    end
  end

end
