# This controller manages the CRUD operations for bonuses associated with stocks. It allows users to view, create, and manage bonuses for a specific stock.
class BonusesController < AuthenticatedController
  before_action :set_stock

  def index
    @bonuses = @stock.bonuses.order(ex_date: :desc)
  end

  def new
    @bonus = @stock.bonuses.new
  end

  def create
    @bonus = @stock.bonuses.new(bonus_params)

    if @bonus.save
      redirect_to stock_bonuses_path(@stock), notice: "Bonus added successfully"
    else
      flash.now[:alert] = @bonus.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_stock
    @stock = Stock.find(params[:stock_id])
  end

  def bonus_params
    params.require(:bonus).permit(:ratio_from, :ratio_to, :ex_date)
  end
end
