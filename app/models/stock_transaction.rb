# This file defines the StockTransaction model, which represents a buy or sell transaction of a stock by a user on a specific platform. It includes associations to the User, Stock,
# and Platform models, as well as an enum for the transaction type (buy or sell). The model does not include any validations or callbacks,
# but it can be extended in the future to include additional functionality such as calculating the total value of the transaction or validating the presence of required attributes.
class StockTransaction < ApplicationRecord
  belongs_to :user
  belongs_to :stock
  belongs_to :platform

  enum transaction_type: { buy: 0, sell: 1 }

  validates :transaction_type, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :transaction_date, presence: true
end
