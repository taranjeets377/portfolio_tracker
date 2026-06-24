module Portfolio
  class AnalyticsService
    XIRR_MAX_ITERATIONS = 100
    XIRR_TOLERANCE = 1e-7
    XIRR_MIN_RATE = -0.999999999

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
        xirr: xirr
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

    def xirr
      return nil if user.stock_transactions.none?

      cash_flows = xirr_cash_flows
      return nil unless valid_xirr_cash_flows?(cash_flows)

      rate = solve_xirr(cash_flows)
      return nil if rate.nil?

      (rate * 100).round(2)
    end

    # XIRR needs one dated cash-flow series that combines historical activity
    # with today's unrealized portfolio value as the terminal inflow.
    def xirr_cash_flows
      (
        transaction_cash_flows +
        dividend_cash_flows +
        current_value_cash_flow
      ).sort_by { |cash_flow| cash_flow[:date] }
    end

    def transaction_cash_flows
      user.stock_transactions.order(:transaction_date, :id).filter_map do |transaction|
        amount = transaction.quantity.to_f * transaction.price.to_f
        amount *= -1 if transaction.buy?
        amount *= 1 if transaction.sell?

        build_cash_flow(amount: amount, date: transaction.transaction_date)
      end
    end

    def dividend_cash_flows
      user.dividend_receipts.order(:received_on, :id).filter_map do |receipt|
        amount = receipt.total_amount.presence || (receipt.shares.to_f * receipt.amount_per_share.to_f)
        build_cash_flow(amount: amount.to_f, date: receipt.received_on)
      end
    end

    def current_value_cash_flow
      [build_cash_flow(amount: totals[:total_current].to_f, date: Date.current)].compact
    end

    def build_cash_flow(amount:, date:)
      return if date.blank? || amount.zero?

      {
        amount: amount,
        date: date
      }
    end

    def valid_xirr_cash_flows?(cash_flows)
      return false if cash_flows.empty?

      has_negative_flow = cash_flows.any? { |cash_flow| cash_flow[:amount].negative? }
      has_positive_flow = cash_flows.any? { |cash_flow| cash_flow[:amount].positive? }

      has_negative_flow && has_positive_flow
    end

    # Newton-Raphson iteratively searches for the discount rate that drives the
    # dated net present value of all portfolio cash flows to zero.
    def solve_xirr(cash_flows, initial_guess = 0.1)
      rate = initial_guess

      XIRR_MAX_ITERATIONS.times do
        npv = xnpv(cash_flows, rate)
        return rate if npv.abs < XIRR_TOLERANCE

        derivative = xnpv_derivative(cash_flows, rate)
        return nil if derivative.zero? || !derivative.finite?

        next_rate = rate - (npv / derivative)
        return nil unless next_rate.finite?

        next_rate = (rate + XIRR_MIN_RATE) / 2.0 if next_rate <= XIRR_MIN_RATE

        return next_rate if (next_rate - rate).abs < XIRR_TOLERANCE

        rate = next_rate
      end

      nil
    rescue FloatDomainError, ZeroDivisionError
      nil
    end

    # XNPV discounts each cash flow by its exact age in years, unlike standard
    # NPV which assumes evenly spaced periods.
    def xnpv(cash_flows, rate)
      first_date = cash_flows.first[:date]

      cash_flows.sum do |cash_flow|
        years = (cash_flow[:date] - first_date).to_f / 365.25
        cash_flow[:amount] / ((1.0 + rate)**years)
      end
    end

    def xnpv_derivative(cash_flows, rate)
      first_date = cash_flows.first[:date]

      cash_flows.sum do |cash_flow|
        years = (cash_flow[:date] - first_date).to_f / 365.25
        next 0.0 if years.zero?

        # Newton-Raphson updates need the slope of XNPV with respect to the rate.
        -years * cash_flow[:amount] / ((1.0 + rate)**(years + 1.0))
      end
    end

    def portfolio_years
      first_transaction_date = user.stock_transactions.minimum(:transaction_date)
      return nil unless first_transaction_date

      (Date.current - first_transaction_date).to_f / 365.25
    end

    def summary_query
      @summary_query ||= Portfolio::SummaryQuery.new(user)
    end

    private :xirr,
            :xirr_cash_flows,
            :transaction_cash_flows,
            :dividend_cash_flows,
            :current_value_cash_flow,
            :build_cash_flow,
            :valid_xirr_cash_flows?,
            :solve_xirr,
            :xnpv,
            :xnpv_derivative
  end
end
