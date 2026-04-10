# This controller is responsible for handling stock splits. It currently only has an index action that lists all stock splits for a given stock.
class StockSplitsController < AuthenticatedController
  def index
    @stock = Stock.find(params[:stock_id])

    @stock_splits = StockSplits::HistoryQuery.new(@stock).call
  end
end
