require 'rails_helper'

RSpec.describe "Daihou::Infos", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/daihou/infos/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/daihou/infos/show"
      expect(response).to have_http_status(:success)
    end
  end

end
