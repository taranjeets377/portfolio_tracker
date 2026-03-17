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

        SUM(CASE WHEN stock_transactions.transaction_type = 0 THEN quantity ELSE 0 END) AS total_buy_qty,

        SUM(CASE WHEN stock_transactions.transaction_type = 1 THEN quantity ELSE 0 END) AS total_sell_qty,

        SUM(CASE WHEN stock_transactions.transaction_type = 0 THEN quantity * price ELSE 0 END) AS total_buy_value"
      )
      .having(
        "SUM(CASE WHEN stock_transactions.transaction_type = 0 THEN quantity ELSE 0 END) -
        SUM(CASE WHEN stock_transactions.transaction_type = 1 THEN quantity ELSE 0 END) > 0"
      )
  end

  def portfolio_summary
    portfolio_holdings.map do |record|
      total_quantity = record.total_buy_qty.to_i - record.total_sell_qty.to_i

      avg_price =
        if record.total_buy_qty.to_i.positive?
          record.total_buy_value.to_f / record.total_buy_qty
        else
          0.0
        end

      invested_value = total_quantity * avg_price

      {
        stock_name: record.name,
        symbol: record.symbol,
        quantity: total_quantity,
        avg_price: avg_price.round(2),
        invested_value: invested_value.round(2)
      }
    end
  end
end
