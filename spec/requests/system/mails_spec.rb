require 'rails_helper'

RSpec.describe "System::Mails", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/system/mails/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/system/mails/new"
      expect(response).to have_http_status(:success)
    end
  end

end
