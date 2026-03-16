# This migration creates the stock_categories table with a UUID primary key and a name column.
class CreateStockCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_categories, id: :uuid do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :stock_categories, :name, unique: true
  end
end
