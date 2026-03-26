FactoryBot.define do
  factory :stock do
    name { Faker::Company.name }
    sequence(:symbol) { |n| "SYM#{n}" }

    association :stock_sector
    association :stock_category
  end
end
