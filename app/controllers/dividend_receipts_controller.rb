# Controller for managing dividend receipts. It allows users to view their dividend history, add new dividend receipts
# and ensures that the necessary associations and validations are in place when creating a new receipt.
class DividendReceiptsController < AuthenticatedController
  def index
    @dividends = current_user.dividend_receipts
                             .includes(:stock)
                             .order(received_on: :desc)
  end

  def new
    @dividend = DividendReceipt.new
    @stocks = Stock.order(:name)
  end

  def create
    stock = Stock.find(dividend_params[:stock_id])

    Dividends::Create.call(
      user: current_user,
      stock: stock,
      record_date: params[:record_date],
      received_on: dividend_params[:received_on],
      amount_per_share: dividend_params[:amount_per_share]
    )

    redirect_to dividends_path, notice: "Dividend recorded successfully"

  rescue ArgumentError => e
    redirect_to new_dividend_path, alert: e.message

  rescue ActiveRecord::RecordInvalid => e
    @stocks = Stock.order(:name)
    flash.now[:alert] = e.message
    render :new, status: :unprocessable_entity
  end

  private

  def dividend_params
    params.require(:dividend_receipt).permit(
      :stock_id,
      :amount_per_share,
      :received_on
    )
  end
end
