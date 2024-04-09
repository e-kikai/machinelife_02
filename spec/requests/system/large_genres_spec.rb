require 'rails_helper'

RSpec.describe "System::LargeGenres", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/system/large_genres/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/system/large_genres/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/system/large_genres/edit"
      expect(response).to have_http_status(:success)
    end
  end

end
