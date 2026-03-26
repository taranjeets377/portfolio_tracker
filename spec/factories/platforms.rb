FactoryBot.define do
  factory :platform do
    sequence(:name) { |n| "Platform #{n}" }
    sequence(:code) { |n| "platform_#{n}" }
  end
end
