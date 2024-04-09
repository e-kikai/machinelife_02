require 'rails_helper'

RSpec.describe "System::Infos", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/system/infos/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/system/infos/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/system/infos/edit"
      expect(response).to have_http_status(:success)
    end
  end

end
