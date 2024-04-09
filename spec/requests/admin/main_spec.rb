require 'rails_helper'

RSpec.describe "Admin::Mains", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/main/index"
      expect(response).to have_http_status(:success)
    end
  end

end
