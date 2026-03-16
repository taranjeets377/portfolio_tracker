# This controller manages the CRUD operations for stocks in the Personal Portfolio Tracker application. It includes actions for listing all stocks (index),
# displaying a form for creating a new stock (new), creating a stock (create), and showing details of a specific stock (show).
# Each action will be implemented to handle the corresponding HTTP requests and interact with the Stock model to perform the necessary database operations.
class StocksController < AuthenticatedController
  def index
    @stocks = Stock.includes(:stock_sector, :stock_category).order(:symbol)
  end

  def new
    @stock = Stock.new
    load_master_data
  end

  def create
    @stock = Stock.new(stock_params)

    if @stock.save
      redirect_to stocks_path, notice: "Stock created successfully"
    else
      load_master_data
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @stock = Stock.find(params[:id])
  end

  private

  def stock_params
    params.require(:stock).permit(
      :name,
      :symbol,
      :stock_sector_id,
      :stock_category_id
    )
  end

  def load_master_data
    @sectors = StockSector.order(:name)
    @categories = StockCategory.order(:name)
  end
end
