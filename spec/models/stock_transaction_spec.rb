require "rails_helper"

RSpec.describe StockTransaction, type: :model do
  let(:user) { create(:user) }
  let(:stock) { create(:stock) }
  let(:platform) { create(:platform) }

  describe "scopes" do
    let!(:buy_txn) do
      create(:stock_transaction,
             user: user,
             stock: stock,
             platform: platform,
             transaction_type: :buy,
             quantity: 10,
             price: 100,
             transaction_date: Date.today)
    end

    let!(:sell_txn) do
      create(:stock_transaction,
             user: user,
             stock: stock,
             platform: platform,
             transaction_type: :sell,
             quantity: 5,
             price: 120,
             transaction_date: Date.today)
    end

    it "returns only buy transactions" do
      expect(StockTransaction.buys).to include(buy_txn)
      expect(StockTransaction.buys).not_to include(sell_txn)
    end

    it "returns only sell transactions" do
      expect(StockTransaction.sells).to include(sell_txn)
      expect(StockTransaction.sells).not_to include(buy_txn)
    end
  end
end
