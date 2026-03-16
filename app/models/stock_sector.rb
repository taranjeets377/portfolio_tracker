# This model represents a stock sector, which is a category of stocks that share similar characteristics or operate in the same industry. Each stock sector has a name and a unique code,
# and it can have many associated stocks. The model includes validations to ensure that the name and code are present and that the code is unique across all stock sectors.
class StockSector < ApplicationRecord
  has_many :stocks

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
end
