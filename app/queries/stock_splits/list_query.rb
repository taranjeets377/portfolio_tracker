# This query object is responsible for fetching the list of stock splits for a given stock. It takes a stock as an argument and returns the stock splits ordered by ex_date in descending order.
module StockSplits
  # Query object for fetching stock split history for a given stock.
  class ListQuery
    def initialize(stock)
      @stock = stock
    end

    def call
      @stock.stock_splits.order(ex_date: :desc)
    end
  end
end
