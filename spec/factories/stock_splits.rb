FactoryBot.define do
  factory :stock_split do
    association :stock
    ratio_from { 1 }
    ratio_to { 5 }
    ex_date { Date.today }
  end
end
