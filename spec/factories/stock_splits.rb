FactoryBot.define do
  factory :stock_split do
    stock { nil }
    ratio_from { "9.99" }
    ratio_to { "9.99" }
    ex_date { "2026-03-29" }
  end
end
