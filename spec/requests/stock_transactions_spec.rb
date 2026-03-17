require "rails_helper"

RSpec.describe "StockTransactions", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET /index" do
    it "returns http success" do
      get transactions_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get new_transaction_path
      expect(response).to have_http_status(:success)
    end
  end
end
