require 'rails_helper'

RSpec.describe "Catalogs", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/catalogs/show"
      expect(response).to have_http_status(:success)
    end
  end

end
