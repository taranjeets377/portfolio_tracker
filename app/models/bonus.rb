# This model represents a stock bonus, which is a corporate action where a company issues additional shares to its existing shareholders.
# Each bonus has a ratio (from and to) that indicates how many new shares are given for each existing share, as well as an ex-date that determines when the bonus takes effect.
class Bonus < ApplicationRecord
  belongs_to :stock

  validates :ratio_from, presence: true, numericality: { greater_than: 0 }
  validates :ratio_to, presence: true, numericality: { greater_than: 0 }
  validates :ex_date, presence: true

  validate :ratio_must_change

  private

  def ratio_must_change
    return if ratio_from.nil? || ratio_to.nil?

    # Allow 1:1 bonus
    errors.add(:base, "Invalid bonus ratio") if ratio_from == ratio_to && ratio_from != 1
  end
end
