class CreateDividends < ActiveRecord::Migration[7.0]
  def change
    create_table :dividends, id: :uuid do |t|
      t.references :stock, null: false, foreign_key: true, type: :uuid
      t.decimal :amount_per_share
      t.date :record_date
      t.date :payment_date

      t.timestamps
    end
  end
end
