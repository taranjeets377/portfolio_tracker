require 'rails_helper'

RSpec.describe StockSplit, type: :model do
  it "is invalid when ratio_from equals ratio_to" do
    split = build(:stock_split, ratio_from: 1, ratio_to: 1)

    expect(split).not_to be_valid
    expect(split.errors[:base]).to include("Split ratio must change (e.g., 1:5, 2:1)")
  end
end
