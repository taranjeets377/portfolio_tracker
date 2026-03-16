#  This migration creates the stock_sectors table with a UUID primary key and a name column.
class CreateStockSectors < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_sectors, id: :uuid do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :stock_sectors, :name, unique: true
  end
end
