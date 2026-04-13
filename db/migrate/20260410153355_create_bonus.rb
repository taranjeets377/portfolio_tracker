# This migration creates the bonuses table, which will store information about stock bonuses. Each bonus is associated with a stock and has a ratio (from and to) as well as an ex-date.
class CreateBonus < ActiveRecord::Migration[7.0]
  def change
    create_table :bonuses, id: :uuid do |t| # ✅ FIXED (plural)
      t.references :stock, null: false, type: :uuid # also fix this

      t.decimal :ratio_from, precision: 10, scale: 2, null: false
      t.decimal :ratio_to, precision: 10, scale: 2, null: false

      t.date :ex_date, null: false

      t.timestamps
    end

    add_index :bonuses, [:stock_id, :ex_date], unique: true
  end
end
