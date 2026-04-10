require 'rails_helper'

RSpec.describe "StockSplits", type: :request do
  let(:user) { create(:user) }
  let(:stock) { create(:stock) }

  before do
    sign_in user
  end

  describe "GET /index" do
    it "returns http success" do
      get stock_stock_splits_path(stock)

      expect(response).to have_http_status(:success)
    end

    it "returns stock splits for the stock" do
      split = create(:stock_split, stock: stock)

      get stock_stock_splits_path(stock)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("#{split.ratio_from}:#{split.ratio_to}")
    end
  end
end
