# User model with Devise authentication.
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, if: :password_required?

  has_many :stock_transactions, dependent: :destroy
  has_many :dividend_receipts, dependent: :destroy

  def shares_on(stock, date)
    buys = stock_transactions
           .where(stock: stock)
           .where("transaction_date <= ?", date)
           .buy
           .sum(:quantity)

    sells = stock_transactions
            .where(stock: stock)
            .where("transaction_date <= ?", date)
            .sell
            .sum(:quantity)

    buys - sells
  end

  def total_dividend_received
    dividend_receipts.sum("shares * amount_per_share")
  end
end
