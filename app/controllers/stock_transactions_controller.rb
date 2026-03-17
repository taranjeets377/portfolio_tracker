# This controller manages stock transactions (buys and sells) for the user's portfolio.
class StockTransactionsController < AuthenticatedController
  def index
    @transactions = current_user.stock_transactions.includes(:stock, :platform).order(transaction_date: :desc)
  end

  def new
    @transaction = StockTransaction.new
    load_dependencies
  end

  def create
    Transactions::Create.call(transaction_params.merge(user: current_user))

    redirect_to transactions_path, notice: "Transaction created successfully"
  rescue StandardError => e
    @transaction = StockTransaction.new(transaction_params)
    load_dependencies
    flash.now[:alert] = e.message
    render :new, status: :unprocessable_entity
  end

  private

  def transaction_params
    params.require(:stock_transaction).permit(
      :stock_id,
      :platform_id,
      :transaction_type,
      :quantity,
      :price,
      :transaction_date
    )
  end

  def load_dependencies
    @stocks = Stock.all.order(:name)
    @platforms = Platform.all.order(:name)
  end
end
