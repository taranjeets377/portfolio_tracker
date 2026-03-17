class CreateStockTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_transactions, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :stock, null: false, foreign_key: true, type: :uuid
      t.references :platform, null: false, foreign_key: true, type: :uuid
      t.integer :transaction_type
      t.integer :quantity
      t.decimal :price
      t.date :transaction_date

      t.timestamps
    end
  end
end
