FactoryBot.define do
  factory :stock_transaction do
    user { nil }
    stock { nil }
    platform { nil }
    transaction_type { 1 }
    quantity { 1 }
    price { "9.99" }
    transaction_date { "2026-03-17" }
  end
end
