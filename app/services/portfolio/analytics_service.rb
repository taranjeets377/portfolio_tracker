module Portfolio
  class AnalyticsService
    def initialize(user)
      @user = user
    end

    def call
      {
        total_invested: totals[:total_invested],
        current_value: totals[:total_current],
        profit_loss: totals[:total_profit_loss],
        allocation: {},
        dividend_yield: nil,
        cagr: nil,
        xirr: nil
      }
    end

    private

    attr_reader :user

    def totals
      @totals ||= summary_query.totals
    end

    def summary_query
      @summary_query ||= Portfolio::SummaryQuery.new(user)
    end
  end
end
