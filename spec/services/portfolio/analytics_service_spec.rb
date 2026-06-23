require "rails_helper"

RSpec.describe Portfolio::AnalyticsService do
  describe "#call" do
    let(:user) { create(:user) }

    it "returns the analytics payload shape" do
      result = described_class.new(user).call

      expect(result.keys).to contain_exactly(
        :total_invested,
        :current_value,
        :profit_loss,
        :allocation,
        :dividend_yield,
        :cagr,
        :xirr
      )
    end

    it "returns placeholders for analytics that are not implemented yet" do
      result = described_class.new(user).call

      expect(result[:allocation]).to eq({})
      expect(result[:dividend_yield]).to be_nil
      expect(result[:cagr]).to be_nil
      expect(result[:xirr]).to be_nil
    end

    it "reuses the portfolio summary totals for headline values" do
      totals = {
        total_invested: 1_000.0,
        total_current: 1_125.0,
        total_profit_loss: 125.0
      }
      summary_query = instance_double(Portfolio::SummaryQuery, totals: totals)

      expect(Portfolio::SummaryQuery).to receive(:new).with(user).and_return(summary_query)

      result = described_class.new(user).call

      expect(result[:total_invested]).to eq(1_000.0)
      expect(result[:current_value]).to eq(1_125.0)
      expect(result[:profit_loss]).to eq(125.0)
    end
  end
end
