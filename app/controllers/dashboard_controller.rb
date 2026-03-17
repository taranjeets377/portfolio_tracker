# Displays the user dashboard.
class DashboardController < AuthenticatedController
  def index
    @portfolio = Portfolio::SummaryQuery.new(current_user).call
  end
end
