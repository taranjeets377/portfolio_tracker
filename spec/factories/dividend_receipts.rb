FactoryBot.define do
  factory :dividend_receipt do
    user
    stock

    dividend do
      association :dividend, stock: stock
    end

    shares { 10 }
    amount_per_share { 5 }
    received_on { Date.today }
  end
end
