module Portfolio
  # Query object to calculate monthly investment for a user
  class MonthlyInvestmentQuery
    def initialize(user)
      @user = user
    end

    def call
      monthly_data.map do |record|
        {
          month: format_month(record.month),
          total_invested: record.total_invested.to_f.round(2)
        }
      end
    end

    private

    attr_reader :user

    def monthly_data
      user.stock_transactions
          .buy
          .group("DATE_TRUNC('month', transaction_date)")
          .select(
            "DATE_TRUNC('month', transaction_date) AS month,
             SUM(quantity * price) AS total_invested"
          )
          .order("month ASC")
    end

    def format_month(date)
      date.strftime("%b %Y") # Jan 2026
    end
  end
end
