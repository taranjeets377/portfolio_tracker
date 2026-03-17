# This file defines the Platform model, which represents a trading platform where users can buy or sell stocks. It includes associations to the StockTransaction model,
# which represents individual transactions made on the platform. This model also includes validations to ensure that each platform has a unique name and code, and that both attributes are present.
# The dependent: :restrict_with_exception option on the has_many association ensures that a platform cannot be deleted if there are any associated stock transactions, preventing integrity issues.
class Platform < ApplicationRecord
  has_many :stock_transactions, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
end
