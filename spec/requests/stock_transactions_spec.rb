require 'rails_helper'

RSpec.describe "StockTransactions", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/stock_transactions/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/stock_transactions/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/stock_transactions/create"
      expect(response).to have_http_status(:success)
    end
  end

end
