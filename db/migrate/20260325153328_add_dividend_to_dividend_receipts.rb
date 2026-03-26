class AddDividendToDividendReceipts < ActiveRecord::Migration[7.0]
  def change
    add_reference :dividend_receipts, :dividend, null: false, foreign_key: true, type: :uuid
  end
end
