# Displays portfolio analytics for the current user.
class AnalyticsController < AuthenticatedController
  def index
    @analytics = Portfolio::AnalyticsService.new(current_user).call
  end
end
