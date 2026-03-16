# This migration creates the stocks table with a UUID primary key, name and symbol columns, and foreign keys to the stock_sectors and stock_categories tables.
class CreateStocks < ActiveRecord::Migration[7.0]
  def change
    create_table :stocks, id: :uuid do |t|
      t.string :name, null: false
      t.string :symbol, null: false
      t.references :stock_sector, null: false, foreign_key: true, type: :uuid
      t.references :stock_category, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :stocks, :symbol, unique: true
  end
end
