# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2026_04_10_153355) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "bonuses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "stock_id", null: false
    t.decimal "ratio_from", precision: 10, scale: 2, null: false
    t.decimal "ratio_to", precision: 10, scale: 2, null: false
    t.date "ex_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stock_id", "ex_date"], name: "index_bonuses_on_stock_id_and_ex_date", unique: true
    t.index ["stock_id"], name: "index_bonuses_on_stock_id"
  end

  create_table "dividend_receipts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "stock_id", null: false
    t.integer "shares"
    t.decimal "amount_per_share"
    t.decimal "total_amount"
    t.date "received_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "dividend_id", null: false
    t.index ["dividend_id"], name: "index_dividend_receipts_on_dividend_id"
    t.index ["stock_id"], name: "index_dividend_receipts_on_stock_id"
    t.index ["user_id"], name: "index_dividend_receipts_on_user_id"
  end

  create_table "dividends", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "stock_id", null: false
    t.decimal "amount_per_share"
    t.date "record_date"
    t.date "payment_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stock_id"], name: "index_dividends_on_stock_id"
  end

  create_table "platforms", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stock_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code", null: false
    t.index ["code"], name: "index_stock_categories_on_code", unique: true
    t.index ["name"], name: "index_stock_categories_on_name", unique: true
  end

  create_table "stock_sectors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code", null: false
    t.index ["code"], name: "index_stock_sectors_on_code", unique: true
    t.index ["name"], name: "index_stock_sectors_on_name", unique: true
  end

  create_table "stock_splits", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "stock_id", null: false
    t.decimal "ratio_from", precision: 10, scale: 2, null: false
    t.decimal "ratio_to", precision: 10, scale: 2, null: false
    t.date "ex_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stock_id", "ex_date"], name: "index_stock_splits_on_stock_id_and_ex_date", unique: true
    t.index ["stock_id"], name: "index_stock_splits_on_stock_id"
  end

  create_table "stock_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "stock_id", null: false
    t.uuid "platform_id", null: false
    t.integer "transaction_type"
    t.integer "quantity"
    t.decimal "price"
    t.date "transaction_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["platform_id"], name: "index_stock_transactions_on_platform_id"
    t.index ["stock_id"], name: "index_stock_transactions_on_stock_id"
    t.index ["user_id"], name: "index_stock_transactions_on_user_id"
  end

  create_table "stocks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "symbol", null: false
    t.uuid "stock_sector_id", null: false
    t.uuid "stock_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stock_category_id"], name: "index_stocks_on_stock_category_id"
    t.index ["stock_sector_id"], name: "index_stocks_on_stock_sector_id"
    t.index ["symbol"], name: "index_stocks_on_symbol", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "dividend_receipts", "dividends"
  add_foreign_key "dividend_receipts", "stocks"
  add_foreign_key "dividend_receipts", "users"
  add_foreign_key "dividends", "stocks"
  add_foreign_key "stock_transactions", "platforms"
  add_foreign_key "stock_transactions", "stocks"
  add_foreign_key "stock_transactions", "users"
  add_foreign_key "stocks", "stock_categories"
  add_foreign_key "stocks", "stock_sectors"
end
