require "rails_helper"

RSpec.describe "Analytics", type: :request do
  let(:user) { create(:user) }
  let(:analytics_service) { instance_double(Portfolio::AnalyticsService, call: analytics_payload) }
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
      expect(response.body).to include("Growth chart will be added in PPT-102")
      expect(response.body).to include("Not yet calculated")
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
    end
  end
end
