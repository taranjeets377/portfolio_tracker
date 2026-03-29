module CorporateActions
  module StockSplits
    # This service adjusts the quantity and average price of a stock based on any applicable stock splits that have occurred up to a specified date.
    # It takes into account the ratio of each split and applies it sequentially to calculate the final adjusted quantity and average price.
    class AdjustmentService
      def initialize(stock:, quantity:, avg_price:, as_of: Date.today)
        @stock = stock
        @quantity = quantity
        @avg_price = avg_price
        @as_of = as_of
      end

      def call
        applicable_splits.each do |split|
          apply_split(split)
        end

        result
      end

      private

      attr_reader :stock, :as_of
      attr_accessor :quantity, :avg_price

      def applicable_splits
        stock.stock_splits
             .where("ex_date <= ?", as_of)
             .order(:ex_date)
      end

      def apply_split(split)
        ratio = split.ratio_to.to_d / split.ratio_from.to_d

        self.quantity = quantity * ratio
        self.avg_price = avg_price / ratio
      end

      def result
        {
          quantity: quantity.to_f,
          avg_price: avg_price.to_f
        }
      end
    end
  end
end
