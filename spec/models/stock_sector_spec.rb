require "rails_helper"

RSpec.describe StockSector, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:code) }
end
