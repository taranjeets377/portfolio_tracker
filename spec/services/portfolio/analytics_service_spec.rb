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

      expect(result[:cagr]).to be_nil
      expect(result[:xirr]).to be_nil
    end

    it "reuses the portfolio summary totals for headline values" do
      totals = {
        total_invested: 1_000.0,
        total_current: 1_125.0,
        total_profit_loss: 125.0
      }
      summary_query = instance_double(Portfolio::SummaryQuery, totals: totals, call: [])

      expect(Portfolio::SummaryQuery).to receive(:new).with(user).and_return(summary_query)

      result = described_class.new(user).call

      expect(result[:total_invested]).to eq(1_000.0)
      expect(result[:current_value]).to eq(1_125.0)
      expect(result[:profit_loss]).to eq(125.0)
    end

    it "returns an empty allocation when there is no current portfolio value" do
      result = described_class.new(user).call

      expect(result[:allocation]).to eq([])
    end

    it "calculates allocation from portfolio summary current values" do
      totals = {
        total_invested: 1_000.0,
        total_current: 1_500.0,
        total_profit_loss: 500.0
      }
      holdings = [
        {
          stock_name: "Bharat Electronics",
          symbol: "BEL",
          current_value: 1_000.0
        },
        {
          stock_name: "Tata Consultancy Services",
          symbol: "TCS",
          current_value: 500.0
        }
      ]
      summary_query = instance_double(Portfolio::SummaryQuery, totals: totals, call: holdings)

      expect(Portfolio::SummaryQuery).to receive(:new).with(user).and_return(summary_query)

      result = described_class.new(user).call

      expect(result[:allocation]).to eq(
        [
          {
            stock_name: "Bharat Electronics",
            symbol: "BEL",
            current_value: 1_000.0,
            allocation_percentage: 66.67
          },
          {
            stock_name: "Tata Consultancy Services",
            symbol: "TCS",
            current_value: 500.0,
            allocation_percentage: 33.33
          }
        ]
      )
    end

    it "returns zero dividend yield when no dividends exist" do
      summary_query = instance_double(
        Portfolio::SummaryQuery,
        totals: {
          total_invested: 1_000.0,
          total_current: 1_000.0,
          total_profit_loss: 0.0
        },
        call: []
      )

      expect(Portfolio::SummaryQuery).to receive(:new).with(user).and_return(summary_query)

      result = described_class.new(user).call

      expect(result[:dividend_yield]).to eq(0)
    end

    it "returns zero dividend yield when current portfolio value is zero" do
      create(:dividend_receipt, user: user, shares: 10, amount_per_share: 5)
      summary_query = instance_double(
        Portfolio::SummaryQuery,
        totals: {
          total_invested: 0.0,
          total_current: 0.0,
          total_profit_loss: 0.0
        },
        call: []
      )

      expect(Portfolio::SummaryQuery).to receive(:new).with(user).and_return(summary_query)

      result = described_class.new(user).call

      expect(result[:dividend_yield]).to eq(0)
    end

    it "calculates dividend yield from total dividends received and current portfolio value" do
      create(:dividend_receipt, user: user, shares: 10, amount_per_share: 5)
      summary_query = instance_double(
        Portfolio::SummaryQuery,
        totals: {
          total_invested: 900.0,
          total_current: 1_200.0,
          total_profit_loss: 300.0
        },
        call: []
      )

      expect(Portfolio::SummaryQuery).to receive(:new).with(user).and_return(summary_query)
      expect(user).to receive(:total_dividend_received).and_call_original

      result = described_class.new(user).call

      expect(result[:dividend_yield]).to eq(4.17)
    end
  end
end
