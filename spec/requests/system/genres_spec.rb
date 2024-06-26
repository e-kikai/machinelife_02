require 'rails_helper'

RSpec.describe "System::Genres", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/system/genres/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/system/genres/edit"
      expect(response).to have_http_status(:success)
    end
  end

end
