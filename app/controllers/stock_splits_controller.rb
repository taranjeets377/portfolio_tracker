# This controller is responsible for handling stock splits. It currently only has an index action that lists all stock splits for a given stock.
class StockSplitsController < AuthenticatedController
  before_action :set_stock

  def index
    @stock_splits = StockSplits::ListQuery.new(@stock).call
  end

  def new
    @stock_split = @stock.stock_splits.new
  end

  def create
    @stock_split = @stock.stock_splits.new(stock_split_params)

    if @stock_split.save
      redirect_to stock_stock_splits_path(@stock), notice: "Stock split added successfully"
    else
      flash.now[:alert] = @stock_split.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_stock
    @stock = Stock.find(params[:stock_id])
  end

  def stock_split_params
    params.require(:stock_split).permit(:ratio_from, :ratio_to, :ex_date)
  end
end
