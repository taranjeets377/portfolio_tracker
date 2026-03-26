class CreateDividendReceipts < ActiveRecord::Migration[7.0]
  def change
    create_table :dividend_receipts, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :stock, null: false, foreign_key: true, type: :uuid
      t.integer :shares
      t.decimal :amount_per_share
      t.decimal :total_amount
      t.date :received_on

      t.timestamps
    end
  end
end
