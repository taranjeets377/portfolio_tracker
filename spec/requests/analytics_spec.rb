require "rails_helper"

RSpec.describe "Analytics", type: :request do
  let(:user) { create(:user) }
  let(:analytics_service) { instance_double(Portfolio::AnalyticsService, call: analytics_payload) }
  let(:monthly_investment_query) { instance_double(Portfolio::MonthlyInvestmentQuery, call: monthly_investments) }
  let(:monthly_investments) { [] }
  let(:analytics_payload) do
    {
      total_invested: 1_000.0,
      current_value: 1_200.0,
      profit_loss: 200.0,
      allocation: [],
      dividend_yield: 2.5,
      cagr: nil,
      xirr: nil
    }
  end

  before do
    allow(Portfolio::AnalyticsService).to receive(:new).and_call_original
    allow(Portfolio::MonthlyInvestmentQuery).to receive(:new).and_call_original
  end

  describe "GET /analytics" do
    it "is accessible to authenticated users" do
      sign_in user

      get analytics_path

      expect(response).to have_http_status(:success)
    end

    it "loads successfully" do
      sign_in user

      get analytics_path

      expect(response.body).to include("Analytics")
      expect(response.body).to include("Total Invested")
      expect(response.body).to include("Portfolio Allocation")
      expect(response.body).to include("Portfolio Growth")
      expect(response.body).to include("Advanced Metrics")
      expect(response.body).to include("Coming in PPT-95")
      expect(response.body).to include("Coming in PPT-96")
      expect(response.body).not_to include("Not yet calculated")
    end

    it "displays an empty allocation message when no allocation data exists" do
      allow(Portfolio::AnalyticsService).to receive(:new).with(user).and_return(analytics_service)
      sign_in user

      get analytics_path

      expect(response.body).to include("No allocation data available.")
      expect(response.body).not_to include("portfolio-allocation-chart")
    end

    it "renders the allocation chart for one holding" do
      single_holding_payload = analytics_payload.merge(
        allocation: [
          {
            stock_name: "Bharat Electronics",
            symbol: "BEL",
            current_value: 1_200.0,
            allocation_percentage: 100.0
          }
        ]
      )
      allow(Portfolio::AnalyticsService).to receive(:new)
        .with(user)
        .and_return(instance_double(Portfolio::AnalyticsService, call: single_holding_payload))
      sign_in user

      get analytics_path

      expect(response.body).to include("portfolio-allocation-chart")
      expect(response.body).to include("BEL")
      expect(response.body).to include("100.0")
      expect(response.body).not_to include("No allocation data available.")
    end

    it "renders the allocation chart for multiple holdings" do
      multi_holding_payload = analytics_payload.merge(
        allocation: [
          {
            stock_name: "Bharat Electronics",
            symbol: "BEL",
            current_value: 600.0,
            allocation_percentage: 50.0
          },
          {
            stock_name: "Hindustan Aeronautics",
            symbol: "HAL",
            current_value: 360.0,
            allocation_percentage: 30.0
          },
          {
            stock_name: "TVS Motors",
            symbol: "TVS",
            current_value: 240.0,
            allocation_percentage: 20.0
          }
        ]
      )
      allow(Portfolio::AnalyticsService).to receive(:new)
        .with(user)
        .and_return(instance_double(Portfolio::AnalyticsService, call: multi_holding_payload))
      sign_in user

      get analytics_path

      expect(response.body).to include("portfolio-allocation-chart")
      expect(response.body).to include("BEL")
      expect(response.body).to include("HAL")
      expect(response.body).to include("TVS")
      expect(response.body).to include("50.0")
      expect(response.body).to include("30.0")
      expect(response.body).to include("20.0")
      expect(response.body).to include("Number of Holdings")
      expect(response.body).to include("3")
    end

    it "displays an empty growth message when no monthly investment data exists" do
      allow(Portfolio::MonthlyInvestmentQuery).to receive(:new).with(user).and_return(monthly_investment_query)
      sign_in user

      get analytics_path

      expect(response.body).to include("No growth data available.")
      expect(response.body).not_to include("portfolio-growth-chart")
    end

    it "renders the portfolio growth chart when monthly investment data exists" do
      growth_data = [
        { month: "Jan 2026", total_invested: 1_000.0 },
        { month: "Feb 2026", total_invested: 1_500.0 }
      ]
      allow(Portfolio::MonthlyInvestmentQuery).to receive(:new)
        .with(user)
        .and_return(instance_double(Portfolio::MonthlyInvestmentQuery, call: growth_data))
      sign_in user

      get analytics_path

      expect(response.body).to include("portfolio-growth-chart")
      expect(response.body).to include("Jan 2026")
      expect(response.body).to include("Feb 2026")
      expect(response.body).to include("1000.0")
      expect(response.body).to include("1500.0")
      expect(response.body).not_to include("No growth data available.")
    end

    it "displays portfolio age from the oldest transaction" do
      allow(Date).to receive(:current).and_return(Date.new(2026, 6, 23))
      create(:stock_transaction, user: user, transaction_date: Date.new(2025, 10, 23))
      sign_in user

      get analytics_path

      expect(response.body).to include("Portfolio Age")
      expect(response.body).to include("8 Months")
    end
  end
end
