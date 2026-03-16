require "rails_helper"

RSpec.describe Stock, type: :model do
  describe "associations" do
    it { should belong_to(:stock_sector) }
    it { should belong_to(:stock_category) }
  end

  describe "validations" do
    subject { create(:stock) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:symbol) }
    it { should validate_uniqueness_of(:symbol).case_insensitive }
  end
end
