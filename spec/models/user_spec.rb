require "rails_helper"

RSpec.describe User, type: :model do
  describe "#total_dividend_received" do
    it "returns total dividend received by user" do
      user = create(:user)
      stock = create(:stock)

      create(:dividend_receipt, user: user, stock: stock, shares: 10, amount_per_share: 5)
      create(:dividend_receipt, user: user, stock: stock, shares: 5, amount_per_share: 4)

      expect(user.total_dividend_received).to eq(10 * 5 + 5 * 4)
    end
  end
end
