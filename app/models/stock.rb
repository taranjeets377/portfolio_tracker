# This model represents a stock, which is a financial instrument that represents ownership in a company. Each stock has a name, a symbol, and belongs to a specific stock sector and stock category.
# The model includes validations to ensure that the name and symbol are present and that the symbol is unique across all stocks.
class Stock < ApplicationRecord
  belongs_to :stock_sector
  belongs_to :stock_category

  validates :name, presence: true
  validates :symbol, presence: true, uniqueness: true
end
