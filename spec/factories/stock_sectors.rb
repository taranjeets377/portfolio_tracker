FactoryBot.define do
  factory :stock_sector do
    sequence(:name) { |n| "Sector #{n}" }
    sequence(:code) { |n| "sector_#{n}" }
  end
end
