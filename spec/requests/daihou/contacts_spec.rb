require 'rails_helper'

RSpec.describe "Daihou::Contacts", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/daihou/contacts/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /index" do
    it "returns http success" do
      get "/daihou/contacts/index"
      expect(response).to have_http_status(:success)
    end
  end

end
