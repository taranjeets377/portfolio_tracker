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

  # ----------------------------------------
  # NEW TESTS — STOCK SPLIT INTERACTION
  # ----------------------------------------

  context "when split is BEFORE record date" do
    before do
      create(:stock_split,
             stock: stock,
             ratio_from: 1,
             ratio_to: 5,
             ex_date: Date.new(2026, 1, 3))
    end

    it "uses adjusted shares for dividend calculation" do
      described_class.call(
        user: user,
        stock: stock,
        record_date: Date.new(2026, 1, 5),
        received_on: Date.new(2026, 1, 10),
        amount_per_share: 5
      )

      receipt = DividendReceipt.order(created_at: :desc).first

      expect(receipt.shares).to eq(50) # 10 × 5
      expect(receipt.total_amount).to eq(250) # 50 × 5
    end
  end

  context "when split is AFTER record date" do
    before do
      create(:stock_split,
             stock: stock,
             ratio_from: 1,
             ratio_to: 5,
             ex_date: Date.new(2026, 1, 10))
    end

    it "does not apply split to dividend shares" do
      described_class.call(
        user: user,
        stock: stock,
        record_date: Date.new(2026, 1, 5),
        received_on: Date.new(2026, 1, 10),
        amount_per_share: 5
      )

      receipt = DividendReceipt.order(created_at: :desc).first

      expect(receipt.shares).to eq(10)
      expect(receipt.total_amount).to eq(50)
    end
  end

  context "with split and bonus before record date" do
    before do
      # Split 1:5 → 10 → 50
      create(:stock_split,
             stock: stock,
             ratio_from: 1,
             ratio_to: 5,
             ex_date: Date.new(2026, 1, 2))

      # Bonus 1:1 → 50 → 100
      create(:bonus,
             stock: stock,
             ratio_from: 1,
             ratio_to: 1,
             ex_date: Date.new(2026, 1, 3))
    end

    it "applies split and bonus correctly for dividend" do
      described_class.call(
        user: user,
        stock: stock,
        record_date: Date.new(2026, 1, 5),
        received_on: Date.new(2026, 1, 10),
        amount_per_share: 5
      )

      receipt = DividendReceipt.order(created_at: :desc).first

      expect(receipt.shares).to eq(100)
      expect(receipt.total_amount).to eq(500)
    end
  end
end
