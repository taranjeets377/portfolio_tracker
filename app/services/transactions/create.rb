module Transactions
  # Service object for creating a stock transaction.
  class Create
    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @params = params
      @user = params[:user]
      @stock = params[:stock]
      @quantity = params[:quantity]
      @transaction_type = params[:transaction_type].to_s
    end

    def call
      ActiveRecord::Base.transaction do
        validate_sell_quantity! if sell?

        create_transaction!
      end
    end

    private

    def sell?
      @transaction_type == "sell"
    end

    def validate_sell_quantity!
      current_quantity = current_stock_quantity

      raise ArgumentError, "Cannot sell more shares than owned" if @quantity > current_quantity
    end

    def current_stock_quantity
      buys = @user.stock_transactions
                  .where(stock: @stock, transaction_type: :buy)
                  .sum(:quantity)

      sells = @user.stock_transactions
                   .where(stock: @stock, transaction_type: :sell)
                   .sum(:quantity)

      buys - sells
    end

    def create_transaction!
      StockTransaction.create!(@params)
    end
  end
end
