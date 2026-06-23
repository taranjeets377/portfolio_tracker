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
        allocation: allocation,
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

    def allocation
      total_current_value = totals[:total_current].to_f
      return [] if total_current_value.zero?

      holdings.map do |holding|
        current_value = holding[:current_value].to_f

        {
          stock_name: holding[:stock_name],
          symbol: holding[:symbol],
          current_value: current_value.round(2),
          allocation_percentage: ((current_value / total_current_value) * 100).round(2)
        }
      end
    end

    def holdings
      @holdings ||= summary_query.call
    end

    def summary_query
      @summary_query ||= Portfolio::SummaryQuery.new(user)
    end
  end
end
