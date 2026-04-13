FactoryBot.define do
  factory :bonus do
    association :stock
    ratio_from { 1 }
    ratio_to { 1 }
    ex_date { Date.today }
  end
end
