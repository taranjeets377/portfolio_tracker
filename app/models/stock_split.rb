# This model represents a stock split event for a particular stock. It includes the ratio of the split (from and to), the ex-date of the split, and associations to the stock it belongs to.
# Validations ensure that the split ratio is valid and that the ex-date is present.
class StockSplit < ApplicationRecord
  belongs_to :stock

  validates :ratio_from, presence: true, numericality: { greater_than: 0 }
  validates :ratio_to, presence: true, numericality: { greater_than: 0 }
  validates :ex_date, presence: true

  validate :ratio_must_change

  private

  def ratio_must_change
    return if ratio_from.nil? || ratio_to.nil?

    errors.add(:base, "Split ratio must change (e.g., 1:5, 2:1)") if ratio_from == ratio_to
  end
end
