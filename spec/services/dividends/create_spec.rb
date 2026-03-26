require "rails_helper"

RSpec.describe Dividends::Create do
  let(:user) { create(:user) }
  let(:stock) { create(:stock) }

  before do
    # User buys shares
    create(:stock_transaction,
           user: user,
           stock: stock,
           transaction_type: :buy,
           quantity: 10,
           price: 100,
           transaction_date: Date.new(2026, 1, 1)
    )
  end

  it "creates dividend and receipt successfully" do
    expect {
      described_class.call(
        user: user,
        stock: stock,
        record_date: Date.new(2026, 1, 5),
        received_on: Date.new(2026, 1, 10),
        amount_per_share: 5
      )
    }.to change(Dividend, :count).by(1)
     .and change(DividendReceipt, :count).by(1)
  end

  it "raises error when no shares held" do
    # Sell before record date
    create(:stock_transaction,
           user: user,
           stock: stock,
           transaction_type: :sell,
           quantity: 10,
           price: 100,
           transaction_date: Date.new(2026, 1, 2)
    )

    expect {
      described_class.call(
        user: user,
        stock: stock,
        record_date: Date.new(2026, 1, 5),
        received_on: Date.new(2026, 1, 10),
        amount_per_share: 5
      )
    }.to raise_error(ArgumentError, "No shares held on record date")
  end
end
