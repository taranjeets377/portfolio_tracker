# Displays the user dashboard.
class DashboardController < AuthenticatedController
  def index
    @portfolio = current_user.portfolio_summary
  end
end
