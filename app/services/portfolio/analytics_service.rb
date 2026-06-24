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
        dividend_yield: dividend_yield,
        cagr: cagr,
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

    def dividend_yield
      current_portfolio_value = totals[:total_current].to_f
      return 0 if current_portfolio_value.zero?

      total_dividend_received = user.total_dividend_received.to_f
      return 0 if total_dividend_received.zero?

      ((total_dividend_received / current_portfolio_value) * 100).round(2)
    end

    def cagr
      total_invested = totals[:total_invested].to_f
      current_value = totals[:total_current].to_f
      years = portfolio_years

      return nil if total_invested <= 0
      return nil if current_value <= 0
      return nil if years.nil? || years <= 0

      growth_factor = current_value / total_invested
      ((growth_factor**(1.0 / years) - 1) * 100).round(2)
    end

    def portfolio_years
      first_transaction_date = user.stock_transactions.minimum(:transaction_date)
      return nil unless first_transaction_date

      (Date.current - first_transaction_date).to_f / 365.25
    end

    def summary_query
      @summary_query ||= Portfolio::SummaryQuery.new(user)
    end
  end
end
