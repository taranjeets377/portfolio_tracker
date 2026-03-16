# This migration adds a code column to the stock_sectors and stock_categories tables, which will be used to store a unique code for each sector and category. The code column is set to be non-nullable and unique, ensuring that each sector and category has a distinct code.
class AddCodeToStockSectorsAndCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :stock_sectors, :code, :string, null: false
    add_column :stock_categories, :code, :string, null: false

    add_index :stock_sectors, :code, unique: true
    add_index :stock_categories, :code, unique: true
  end
end
