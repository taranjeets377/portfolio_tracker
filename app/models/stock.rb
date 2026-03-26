# This model represents a stock, which is a financial instrument that represents ownership in a company. Each stock has a name, a symbol, and belongs to a specific stock sector and stock category.
# The model includes validations to ensure that the name and symbol are present and that the symbol is unique across all stocks.
class Stock < ApplicationRecord
  belongs_to :stock_sector
  belongs_to :stock_category

  before_validation :normalize_symbol

  validates :name, presence: true
  validates :symbol, presence: true, uniqueness: { case_sensitive: false }

  has_many :stock_transactions, dependent: :restrict_with_exception
  has_many :dividend_receipts, dependent: :destroy

  private

  def normalize_symbol
    self.symbol = symbol&.upcase
  end
end
