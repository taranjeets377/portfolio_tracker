require 'rails_helper'

RSpec.describe "Bonuses", type: :request do
  let(:user) { create(:user) }
  let(:stock) { create(:stock) }

  before do
    sign_in user
  end

  describe "GET /index" do
    it "returns http success" do
      get stock_bonuses_path(stock)

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get new_stock_bonus_path(stock)

      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "creates a bonus and redirects" do
      expect do
        post stock_bonuses_path(stock), params: {
          bonus: {
            ratio_from: 1,
            ratio_to: 1,
            ex_date: Date.today
          }
        }
      end.to change(Bonus, :count).by(1)

      expect(response).to redirect_to(stock_bonuses_path(stock))
    end
  end
end
