# This model represents a dividend associated with a stock. It has a one-to-many relationship with DividendReceipt, which tracks the individual dividend payments received by users for that stock.
# The Dividend model can be used to store information about the dividend, such as the amount per share and the date it was issued.
class Dividend < ApplicationRecord
  belongs_to :stock
  has_many :dividend_receipts, dependent: :destroy

  validates :amount_per_share, presence: true, numericality: { greater_than: 0 }
  validates :record_date, presence: true
end
