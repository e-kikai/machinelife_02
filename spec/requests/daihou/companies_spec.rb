require 'rails_helper'

RSpec.describe "Daihou::Companies", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/daihou/companies/index"
      expect(response).to have_http_status(:success)
    end
  end

end
