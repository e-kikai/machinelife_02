require 'rails_helper'

RSpec.describe "Admin::Contacts", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/contacts/index"
      expect(response).to have_http_status(:success)
    end
  end

end
