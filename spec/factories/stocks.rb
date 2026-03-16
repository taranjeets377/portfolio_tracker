FactoryBot.define do
  factory :stock do
    name { Faker::Company.name }
    symbol { Faker::Alphanumeric.alphanumeric(number: 4).upcase }

    association :stock_sector
    association :stock_category
  end
end
