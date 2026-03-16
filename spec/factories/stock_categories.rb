FactoryBot.define do
  factory :stock_category do
    sequence(:name) { |n| "Category #{n}" }
    sequence(:code) { |n| "category_#{n}" }
  end
end
