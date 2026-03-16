# This model represents a stock category, which is a classification of stocks based on certain criteria such as industry, market capitalization, or investment style.
# Each stock category has a name and a unique code, and it can have many associated stocks. The model includes validations to ensure that the name and code are present and that the code is unique across all stock categories.
class StockCategory < ApplicationRecord
  has_many :stocks

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
end
