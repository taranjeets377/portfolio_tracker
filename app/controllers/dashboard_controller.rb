# Displays the user dashboard.
class DashboardController < AuthenticatedController
  def index
    summary_query = Portfolio::SummaryQuery.new(current_user)

    @portfolio = summary_query.call
    @totals = summary_query.totals

    @monthly_investments = Portfolio::MonthlyInvestmentQuery.new(current_user).call
  end
end
