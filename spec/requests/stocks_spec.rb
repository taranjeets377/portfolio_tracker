require "rails_helper"

RSpec.describe "Stocks", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET /stocks" do
    it "returns success" do
      get stocks_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "stock search" do
    let!(:hal) { create(:stock, symbol: "HAL", name: "Hindustan Aeronautics") }
    let!(:tvs) { create(:stock, symbol: "TVS", name: "TVS Motors") }

    it "filters stocks by symbol" do
      get stocks_path, params: { query: "HAL" }

      expect(response.body).to include("HAL")
      expect(response.body).not_to include("TVS")
    end

    it "filters stocks by name" do
      get stocks_path, params: { query: "Aeronautics" }

      expect(response.body).to include("HAL")
    end
  end
end
