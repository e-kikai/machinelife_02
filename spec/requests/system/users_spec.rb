require 'rails_helper'

RSpec.describe "System::Users", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/system/users/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/system/users/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/system/users/edit"
      expect(response).to have_http_status(:success)
    end
  end

end
