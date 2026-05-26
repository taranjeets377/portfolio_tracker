module Portfolio
  # Query object for fetching portfolio summary data for a user.
  class SummaryQuery
    def initialize(user)
      @user = user
    end

    def call
      @summary ||= begin
        records = portfolio_holdings.to_a
        stock_ids = records.map(&:stock_id)
        as_of = Date.current
        stocks_by_id = Stock.where(id: stock_ids).index_by(&:id)
        splits_by_stock_id = StockSplit.where(stock_id: stock_ids)
                                        .where("ex_date <= ?", as_of)
                                        .order(:ex_date)
                                        .group_by(&:stock_id)
        bonuses_by_stock_id = Bonus.where(stock_id: stock_ids)
                                    .where("ex_date <= ?", as_of)
                                    .order(:ex_date)
                                    .group_by(&:stock_id)

        records.map do |record|
          build_summary(
            record,
            stocks_by_id.fetch(record.stock_id),
            splits_by_stock_id[record.stock_id] || [],
            bonuses_by_stock_id[record.stock_id] || [],
            as_of
          )
        end
      end
    end

    def totals
      data = call

      total_invested = data.sum { |s| s[:invested_value] }
      total_current = data.sum { |s| s[:current_value] }
      total_pl = data.sum { |s| s[:profit_loss] }

      {
        total_invested: total_invested.round(2),
        total_current: total_current.round(2),
        total_profit_loss: total_pl.round(2)
      }
    end

    private

    def build_summary(record, stock, splits, bonuses, as_of)
      quantity = calculate_quantity(record)
      avg_price = calculate_avg_price(record)

      if quantity.positive?
        # ----------------------------
        # Step 1: Apply Stock Splits
        # ----------------------------
        split_adjusted = CorporateActions::StockSplits::AdjustmentService.new(
          stock: stock,
          quantity: quantity,
          avg_price: avg_price,
          as_of: as_of,
          splits: splits
        ).call

        quantity = split_adjusted[:quantity]
        avg_price = split_adjusted[:avg_price]

        # ----------------------------
        # Step 2: Apply Bonus Shares
        # ----------------------------
        new_quantity = CorporateActions::Bonuses::AdjustmentService.new(
          stock: stock,
          quantity: quantity,
          as_of: as_of,
          bonuses: bonuses
        ).call

        avg_price = (quantity.to_d * avg_price.to_d) / new_quantity.to_d if new_quantity.positive?

        quantity = new_quantity
      end

      invested_value = calculate_invested_value(quantity, avg_price)
      current_price = mock_current_price(avg_price)
      current_value = calculate_current_value(quantity, current_price)
      profit_loss = calculate_profit_loss(current_value, invested_value)

      {
        stock_name: record.name,
        symbol: record.symbol,
        quantity: quantity,
        avg_price: avg_price.round(2),
        invested_value: invested_value.round(2),
        current_price: current_price.round(2),
        current_value: current_value.round(2),
        profit_loss: profit_loss.round(2)
      }
    end

    # ----------------------------
    # Calculation Methods
    # ----------------------------

    def calculate_quantity(record)
      record.total_buy_qty.to_i - record.total_sell_qty.to_i
    end

    def calculate_avg_price(record)
      return 0 unless record.total_buy_qty.to_i.positive?

      record.total_buy_value.to_f / record.total_buy_qty
    end

    def calculate_invested_value(quantity, avg_price)
      quantity * avg_price
    end

    def mock_current_price(avg_price)
      avg_price * (1 + rand(-0.1..0.1))
    end

    def calculate_current_value(quantity, current_price)
      quantity * current_price
    end

    def calculate_profit_loss(current_value, invested_value)
      current_value - invested_value
    end

    # ----------------------------
    # Query
    # ----------------------------

    def portfolio_holdings
      @user.stock_transactions
           .joins(:stock)
           .group("stocks.id", "stocks.name", "stocks.symbol")
           .select(
             "stocks.id AS stock_id,
              stocks.name,
              stocks.symbol,

              SUM(CASE WHEN stock_transactions.transaction_type = 0 THEN quantity ELSE 0 END) AS total_buy_qty,

              SUM(CASE WHEN stock_transactions.transaction_type = 1 THEN quantity ELSE 0 END) AS total_sell_qty,

              SUM(CASE WHEN stock_transactions.transaction_type = 0 THEN quantity * price ELSE 0 END) AS total_buy_value"
           )
           .having(
             "SUM(CASE WHEN stock_transactions.transaction_type = 0 THEN quantity ELSE 0 END) -
              SUM(CASE WHEN stock_transactions.transaction_type = 1 THEN quantity ELSE 0 END) > 0"
           )
    end
  end
end
