import { application } from "./application"
import MonthlyChartController from "./monthly_investment_chart_controller"
import PortfolioAllocationChartController from "./portfolio_allocation_chart_controller"

application.register("monthly-investment-chart", MonthlyChartController)
application.register("portfolio-allocation-chart", PortfolioAllocationChartController)
