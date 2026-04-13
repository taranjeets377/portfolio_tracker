module CorporateActions
  module Bonuses
    # This service is responsible for adjusting the quantity of shares based on the bonuses that have occurred for a given stock.
    # It takes into account the ex-date of the bonuses to ensure that only applicable bonuses are applied.
    class AdjustmentService
      def initialize(stock:, quantity:, as_of: Date.today)
        @stock = stock
        @quantity = quantity
        @as_of = as_of
      end

      def call
        applicable_bonuses.each do |bonus|
          apply_bonus(bonus)
        end

        quantity
      end

      private

      attr_reader :stock, :as_of
      attr_accessor :quantity

      def applicable_bonuses
        stock.bonuses
             .where("ex_date <= ?", as_of)
             .order(:ex_date)
      end

      def apply_bonus(bonus)
        bonus_ratio = bonus.ratio_to.to_d / bonus.ratio_from.to_d

        additional_shares = quantity * bonus_ratio

        self.quantity = quantity + additional_shares
      end
    end
  end
end
