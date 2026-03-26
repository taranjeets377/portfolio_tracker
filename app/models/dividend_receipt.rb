# This model represents a dividend receipt for a stock owned by a user. It includes associations to the User and Stock models, allowing us to track which user received dividends from which stock.
class DividendReceipt < ApplicationRecord
  belongs_to :user
  belongs_to :stock
  belongs_to :dividend

  validates :shares, presence: true, numericality: { greater_than: 0 }
  validates :amount_per_share, presence: true, numericality: { greater_than: 0 }
  validates :received_on, presence: true

  before_validation :calculate_total_amount

  def calculate_total_amount
    return if shares.blank? || amount_per_share.blank?

    self.total_amount = shares * amount_per_share
  end
end
