require "rails_helper"

RSpec.describe Transactions::Create do
  let(:user) { create(:user) }
  let(:stock) { create(:stock) }
  let(:platform) { create(:platform) }

  it "creates a buy transaction successfully" do
    expect do
      described_class.call(
        user: user,
        stock_id: stock.id,
        platform_id: platform.id,
        transaction_type: "buy",
        quantity: 10,
        price: 100,
        transaction_date: Date.today
      )
    end.to change(StockTransaction, :count).by(1)
  end

  it "prevents selling more than owned shares" do
    # First buy
    described_class.call(
      user: user,
      stock_id: stock.id,
      platform_id: platform.id,
      transaction_type: "buy",
      quantity: 5,
      price: 100,
      transaction_date: Date.today
    )

    # Try invalid sell
    expect do
      described_class.call(
        user: user,
        stock_id: stock.id,
        platform_id: platform.id,
        transaction_type: "sell",
        quantity: 10,
        price: 120,
        transaction_date: Date.today
      )
    end.to raise_error(ArgumentError, /Cannot sell more shares/)
  end
end
