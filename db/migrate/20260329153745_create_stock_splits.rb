# This migration creates the stock_splits table, which stores information about stock splits for each stock. Each record includes the stock ID, the ratio of the split (from and to),
# the ex-date of the split, and timestamps for when the record was created and last updated. The table uses UUIDs for the primary key and includes indexes for efficient querying by stock ID and ex-date.
class CreateStockSplits < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_splits, id: :uuid do |t|
      t.uuid :stock_id, null: false

      t.decimal :ratio_from, precision: 10, scale: 2, null: false
      t.decimal :ratio_to, precision: 10, scale: 2, null: false

      t.date :ex_date, null: false

      t.timestamps
    end

    add_index :stock_splits, :stock_id
    add_index :stock_splits, [:stock_id, :ex_date], unique: true
  end
end
