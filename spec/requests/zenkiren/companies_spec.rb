require 'rails_helper'

RSpec.describe "Zenkiren::Companies", type: :request do
  describe "GET /tokyo" do
    it "returns http success" do
      get "/zenkiren/companies/tokyo"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /osaka" do
    it "returns http success" do
      get "/zenkiren/companies/osaka"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /chubu" do
    it "returns http success" do
      get "/zenkiren/companies/chubu"
      expect(response).to have_http_status(:success)
    end
  end

end
