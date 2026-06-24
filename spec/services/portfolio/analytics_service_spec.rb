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

    it "returns nil XIRR when there are no transactions" do
      result = described_class.new(user).call

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

    it "returns nil CAGR when there are no transactions" do
      summary_query = instance_double(
        Portfolio::SummaryQuery,
        totals: {
          total_invested: 1_000.0,
          total_current: 1_200.0,
          total_profit_loss: 200.0
        },
        call: []
      )

      expect(Portfolio::SummaryQuery).to receive(:new).with(user).and_return(summary_query)

      result = described_class.new(user).call

      expect(result[:cagr]).to be_nil
    end

    it "calculates CAGR for one year growth" do
      allow(Date).to receive(:current).and_return(Date.new(2026, 6, 24))
      create(:stock_transaction, user: user, transaction_date: Date.new(2025, 6, 24))
      summary_query = instance_double(
        Portfolio::SummaryQuery,
        totals: {
          total_invested: 1_000.0,
          total_current: 1_144.7,
          total_profit_loss: 144.7
        },
        call: []
      )

      expect(Portfolio::SummaryQuery).to receive(:new).with(user).and_return(summary_query)

      result = described_class.new(user).call

      expect(result[:cagr]).to eq(14.48)
    end

    it "calculates CAGR for multi-year growth" do
      allow(Date).to receive(:current).and_return(Date.new(2026, 6, 24))
      create(:stock_transaction, user: user, transaction_date: Date.new(2023, 6, 24))
      summary_query = instance_double(
        Portfolio::SummaryQuery,
        totals: {
          total_invested: 1_000.0,
          total_current: 1_728.0,
          total_profit_loss: 728.0
        },
        call: []
      )

      expect(Portfolio::SummaryQuery).to receive(:new).with(user).and_return(summary_query)

      result = described_class.new(user).call

      expect(result[:cagr]).to eq(20.0)
    end

    it "returns nil CAGR when total invested value is zero" do
      allow(Date).to receive(:current).and_return(Date.new(2026, 6, 24))
      create(:stock_transaction, user: user, transaction_date: Date.new(2025, 6, 24))
      summary_query = instance_double(
        Portfolio::SummaryQuery,
        totals: {
          total_invested: 0.0,
          total_current: 1_000.0,
          total_profit_loss: 1_000.0
        },
        call: []
      )

      expect(Portfolio::SummaryQuery).to receive(:new).with(user).and_return(summary_query)

      result = described_class.new(user).call

      expect(result[:cagr]).to be_nil
    end

    it "returns nil CAGR when current value is zero" do
      allow(Date).to receive(:current).and_return(Date.new(2026, 6, 24))
      create(:stock_transaction, user: user, transaction_date: Date.new(2025, 6, 24))
      summary_query = instance_double(
        Portfolio::SummaryQuery,
        totals: {
          total_invested: 1_000.0,
          total_current: 0.0,
          total_profit_loss: -1_000.0
        },
        call: []
      )

      expect(Portfolio::SummaryQuery).to receive(:new).with(user).and_return(summary_query)

      result = described_class.new(user).call

      expect(result[:cagr]).to be_nil
    end

    it "returns nil CAGR when portfolio age is zero years" do
      allow(Date).to receive(:current).and_return(Date.new(2026, 6, 24))
      create(:stock_transaction, user: user, transaction_date: Date.new(2026, 6, 24))
      summary_query = instance_double(
        Portfolio::SummaryQuery,
        totals: {
          total_invested: 1_000.0,
          total_current: 1_100.0,
          total_profit_loss: 100.0
        },
        call: []
      )

      expect(Portfolio::SummaryQuery).to receive(:new).with(user).and_return(summary_query)

      result = described_class.new(user).call

      expect(result[:cagr]).to be_nil
    end

    it "calculates XIRR for a realistic gain scenario" do
      allow(Date).to receive(:current).and_return(Date.new(2024, 1, 1))
      create(
        :stock_transaction,
        user: user,
        transaction_type: :buy,
        quantity: 100,
        price: 100,
        transaction_date: Date.new(2023, 1, 1)
      )
      summary_query = instance_double(
        Portfolio::SummaryQuery,
        totals: {
          total_invested: 10_000.0,
          total_current: 12_000.0,
          total_profit_loss: 2_000.0
        },
        call: []
      )

      expect(Portfolio::SummaryQuery).to receive(:new).with(user).and_return(summary_query)

      result = described_class.new(user).call

      expect(result[:xirr]).to be_within(0.05).of(20.0)
    end

    it "calculates XIRR for a loss scenario" do
      allow(Date).to receive(:current).and_return(Date.new(2024, 1, 1))
      create(
        :stock_transaction,
        user: user,
        transaction_type: :buy,
        quantity: 100,
        price: 100,
        transaction_date: Date.new(2023, 1, 1)
      )
      summary_query = instance_double(
        Portfolio::SummaryQuery,
        totals: {
          total_invested: 10_000.0,
          total_current: 8_000.0,
          total_profit_loss: -2_000.0
        },
        call: []
      )

      expect(Portfolio::SummaryQuery).to receive(:new).with(user).and_return(summary_query)

      result = described_class.new(user).call

      expect(result[:xirr]).to be_within(0.05).of(-20.0)
    end

    it "calculates XIRR for multiple investments" do
      current_date = Date.new(2026, 6, 24)
      allow(Date).to receive(:current).and_return(current_date)

      create(
        :stock_transaction,
        user: user,
        transaction_type: :buy,
        quantity: 10,
        price: 100,
        transaction_date: Date.new(2025, 6, 24)
      )
      second_investment_date = Date.new(2025, 12, 24)
      create(
        :stock_transaction,
        user: user,
        transaction_type: :buy,
        quantity: 20,
        price: 50,
        transaction_date: second_investment_date
      )

      target_rate = 0.10
      total_current = 1_000.0 * (1 + target_rate) + (1_000.0 * ((1 + target_rate)**((current_date - second_investment_date).to_f / 365.25)))
      summary_query = instance_double(
        Portfolio::SummaryQuery,
        totals: {
          total_invested: 2_000.0,
          total_current: total_current.round(2),
          total_profit_loss: (total_current - 2_000.0).round(2)
        },
        call: []
      )

      expect(Portfolio::SummaryQuery).to receive(:new).with(user).and_return(summary_query)

      result = described_class.new(user).call

      expect(result[:xirr]).to be_within(0.01).of(10.0)
    end

    it "includes dividend receipts in the XIRR cash flows" do
      current_date = Date.new(2026, 6, 24)
      allow(Date).to receive(:current).and_return(current_date)

      create(
        :stock_transaction,
        user: user,
        transaction_type: :buy,
        quantity: 10,
        price: 100,
        transaction_date: Date.new(2025, 6, 24)
      )
      dividend_date = Date.new(2025, 12, 24)
      create(
        :dividend_receipt,
        user: user,
        shares: 10,
        amount_per_share: 10,
        received_on: dividend_date
      )

      target_rate = 0.15
      total_current = 1_000.0 * (1 + target_rate) - (100.0 * ((1 + target_rate)**((current_date - dividend_date).to_f / 365.25)))
      summary_query = instance_double(
        Portfolio::SummaryQuery,
        totals: {
          total_invested: 1_000.0,
          total_current: total_current.round(2),
          total_profit_loss: (total_current - 1_000.0).round(2)
        },
        call: []
      )

      expect(Portfolio::SummaryQuery).to receive(:new).with(user).and_return(summary_query)

      result = described_class.new(user).call

      expect(result[:xirr]).to be_within(0.01).of(15.0)
    end

    it "returns nil XIRR when there are no positive cash flows" do
      allow(Date).to receive(:current).and_return(Date.new(2026, 6, 24))
      create(
        :stock_transaction,
        user: user,
        transaction_type: :buy,
        quantity: 10,
        price: 100,
        transaction_date: Date.new(2025, 6, 24)
      )
      summary_query = instance_double(
        Portfolio::SummaryQuery,
        totals: {
          total_invested: 1_000.0,
          total_current: 0.0,
          total_profit_loss: -1_000.0
        },
        call: []
      )

      expect(Portfolio::SummaryQuery).to receive(:new).with(user).and_return(summary_query)

      result = described_class.new(user).call

      expect(result[:xirr]).to be_nil
    end

    it "returns nil XIRR when there are no negative cash flows" do
      allow(Date).to receive(:current).and_return(Date.new(2026, 6, 24))
      create(
        :stock_transaction,
        user: user,
        transaction_type: :sell,
        quantity: 10,
        price: 100,
        transaction_date: Date.new(2025, 6, 24)
      )
      summary_query = instance_double(
        Portfolio::SummaryQuery,
        totals: {
          total_invested: 0.0,
          total_current: 500.0,
          total_profit_loss: 500.0
        },
        call: []
      )

      expect(Portfolio::SummaryQuery).to receive(:new).with(user).and_return(summary_query)

      result = described_class.new(user).call

      expect(result[:xirr]).to be_nil
    end

    it "changes XIRR when dividend receipts are present" do
      current_date = Date.new(2026, 6, 24)
      allow(Date).to receive(:current).and_return(current_date)
      create(
        :stock_transaction,
        user: user,
        transaction_type: :buy,
        quantity: 10,
        price: 100,
        transaction_date: Date.new(2025, 6, 24)
      )

      summary_query_without_dividend = instance_double(
        Portfolio::SummaryQuery,
        totals: {
          total_invested: 1_000.0,
          total_current: 1_100.0,
          total_profit_loss: 100.0
        },
        call: []
      )

      allow(Portfolio::SummaryQuery).to receive(:new).with(user).and_return(summary_query_without_dividend)
      xirr_without_dividend = described_class.new(user).call[:xirr]

      create(
        :dividend_receipt,
        user: user,
        shares: 10,
        amount_per_share: 10,
        received_on: Date.new(2025, 12, 24)
      )

      summary_query_with_dividend = instance_double(
        Portfolio::SummaryQuery,
        totals: {
          total_invested: 1_000.0,
          total_current: 1_100.0,
          total_profit_loss: 100.0
        },
        call: []
      )

      allow(Portfolio::SummaryQuery).to receive(:new).with(user).and_return(summary_query_with_dividend)
      xirr_with_dividend = described_class.new(user).call[:xirr]

      expect(xirr_without_dividend).to be_within(0.01).of(10.0)
      expect(xirr_with_dividend).to be > xirr_without_dividend
      expect(xirr_with_dividend).not_to eq(xirr_without_dividend)
    end

    it "calculates XIRR for a buy and sell transaction" do
      allow(Date).to receive(:current).and_return(Date.new(2024, 1, 1))
      create(
        :stock_transaction,
        user: user,
        transaction_type: :buy,
        quantity: 10,
        price: 100,
        transaction_date: Date.new(2023, 1, 1)
      )
      create(
        :stock_transaction,
        user: user,
        transaction_type: :sell,
        quantity: 10,
        price: 120,
        transaction_date: Date.new(2024, 1, 1)
      )
      summary_query = instance_double(
        Portfolio::SummaryQuery,
        totals: {
          total_invested: 1_000.0,
          total_current: 0.0,
          total_profit_loss: 200.0
        },
        call: []
      )

      expect(Portfolio::SummaryQuery).to receive(:new).with(user).and_return(summary_query)

      result = described_class.new(user).call

      expect(result[:xirr]).to be_within(0.05).of(20.0)
    end

    it "returns nil XIRR when all cash flows occur on the same day" do
      current_date = Date.new(2026, 6, 24)
      allow(Date).to receive(:current).and_return(current_date)
      create(
        :stock_transaction,
        user: user,
        transaction_type: :buy,
        quantity: 10,
        price: 100,
        transaction_date: current_date
      )
      summary_query = instance_double(
        Portfolio::SummaryQuery,
        totals: {
          total_invested: 1_000.0,
          total_current: 1_100.0,
          total_profit_loss: 100.0
        },
        call: []
      )

      expect(Portfolio::SummaryQuery).to receive(:new).with(user).and_return(summary_query)

      result = described_class.new(user).call

      expect(result[:xirr]).to be_nil
    end
  end
end
