FactoryBot.define do
  factory :stock_transaction do
    user
    stock
    platform

    transaction_type { :buy }
    quantity { 10 }
    price { 100 }
    transaction_date { Date.today }
  end
end
