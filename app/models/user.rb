# User model with Devise authentication.
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, if: :password_required?

  has_many :stock_transactions, dependent: :destroy

  def portfolio_holdings
    stock_transactions
      .joins(:stock)
      .group("stocks.id", "stocks.name", "stocks.symbol")
      .select(
        "stocks.id,
        stocks.name,
        stocks.symbol,
        SUM(CASE WHEN stock_transactions.transaction_type = 0 THEN quantity ELSE 0 END) -
        SUM(CASE WHEN stock_transactions.transaction_type = 1 THEN quantity ELSE 0 END)
        AS total_quantity"
      )
      .having(
        "SUM(CASE WHEN stock_transactions.transaction_type = 0 THEN quantity ELSE 0 END) -
        SUM(CASE WHEN stock_transactions.transaction_type = 1 THEN quantity ELSE 0 END) > 0"
      )
  end

  def portfolio_summary
    portfolio_holdings.map do |record|
      {
        stock_name: record.name,
        symbol: record.symbol,
        quantity: record.total_quantity.to_i
      }
    end
  end
end
