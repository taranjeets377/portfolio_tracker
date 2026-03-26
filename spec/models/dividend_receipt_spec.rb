require "rails_helper"

RSpec.describe DividendReceipt, type: :model do
  describe "#total_amount" do
    it "calculates total dividend correctly" do
      receipt = create(:dividend_receipt, shares: 10, amount_per_share: 5)

      expect(receipt.total_amount).to eq(50)
    end
  end
end
