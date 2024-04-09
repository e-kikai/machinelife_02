require 'rails_helper'

RSpec.describe "System::Mains", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/system/main/index"
      expect(response).to have_http_status(:success)
    end
  end

end
