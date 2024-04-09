require 'rails_helper'

RSpec.describe "Admin::Machines", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/machines/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/admin/machines/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/admin/machines/edit"
      expect(response).to have_http_status(:success)
    end
  end

end
