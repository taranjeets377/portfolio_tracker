module Transactions
  # Service object for creating a stock transaction.
  class Create
    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @params = params
    end

    def call
      StockTransaction.create!(
        user: @params[:user],
        stock: @params[:stock],
        platform: @params[:platform],
        transaction_type: @params[:transaction_type],
        quantity: @params[:quantity],
        price: @params[:price],
        transaction_date: @params[:transaction_date]
      )
    end
  end
end
