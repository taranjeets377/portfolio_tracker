module Dividends
  # Service to create dividend + receipt
  class Create
    def self.call(user:, stock:, record_date:, received_on:, amount_per_share:)
      new(user, stock, record_date, received_on, amount_per_share).call
    end

    def initialize(user, stock, record_date, received_on, amount_per_share)
      @user = user
      @stock = stock
      @record_date = record_date
      @received_on = received_on
      @amount_per_share = amount_per_share
    end

    def call
      ActiveRecord::Base.transaction do
        shares = calculate_shares!

        dividend = create_dividend!

        create_receipt!(dividend, shares)
      end
    end

    private

    def calculate_shares!
      base_shares = @user.shares_on(@stock, @record_date)

      adjusted_shares = CorporateActions::StockSplits::AdjustmentService.new(
        stock: @stock,
        quantity: base_shares,
        avg_price: 0, # not needed for dividends
        as_of: @record_date
      ).call[:quantity]

      raise ArgumentError, "No shares held on record date" if adjusted_shares <= 0

      adjusted_shares
    end

    def create_dividend!
      Dividend.create!(
        stock: @stock,
        amount_per_share: @amount_per_share,
        record_date: @record_date,
        payment_date: @received_on
      )
    end

    def create_receipt!(dividend, shares)
      @user.dividend_receipts.create!(
        dividend: dividend,
        stock: @stock,
        shares: shares,
        amount_per_share: @amount_per_share,
        received_on: @received_on
      )
    end
  end
end