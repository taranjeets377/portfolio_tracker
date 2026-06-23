# Displays portfolio analytics for the current user.
class AnalyticsController < AuthenticatedController
  def index
    @analytics = Portfolio::AnalyticsService.new(current_user).call
    @monthly_investments = Portfolio::MonthlyInvestmentQuery.new(current_user).call
    @portfolio_age = portfolio_age
    @holdings_count = @analytics[:allocation].count
  end

  private

  def portfolio_age
    oldest_transaction_date = current_user.stock_transactions.minimum(:transaction_date)
    return "--" unless oldest_transaction_date

    months = months_between(oldest_transaction_date, Date.current)

    if months < 12
      "#{months} #{'Month'.pluralize(months)}"
    else
      "#{(months / 12.0).round(1)} Years"
    end
  end

  def months_between(start_date, end_date)
    months = (end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month)
    months -= 1 if end_date.day < start_date.day
    [months, 0].max
  end
end
