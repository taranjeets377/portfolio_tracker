FactoryBot.define do
  factory :dividend do
    stock { nil }
    amount_per_share { "9.99" }
    record_date { "2026-03-25" }
    payment_date { "2026-03-25" }
  end
end
