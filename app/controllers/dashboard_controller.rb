# Displays the user dashboard.
class DashboardController < AuthenticatedController
  def index
    query = Portfolio::SummaryQuery.new(current_user)

    @portfolio = query.call
    @totals = query.totals
  end
end
