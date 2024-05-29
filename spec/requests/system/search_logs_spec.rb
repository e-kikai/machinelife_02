require 'rails_helper'

RSpec.describe "System::SearchLogs", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/system/search_logs/index"
      expect(response).to have_http_status(:success)
    end
  end

end
