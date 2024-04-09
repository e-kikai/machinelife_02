require 'rails_helper'

RSpec.describe "System::XlGenres", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/system/xl_genres/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/system/xl_genres/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/system/xl_genres/edit"
      expect(response).to have_http_status(:success)
    end
  end

end
