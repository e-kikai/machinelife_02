require 'rails_helper'

RSpec.describe "Admin::Urikais", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/urikais/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/admin/urikais/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/admin/urikais/show"
      expect(response).to have_http_status(:success)
    end
  end

end
