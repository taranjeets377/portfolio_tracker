import { application } from "./application"
import MonthlyChartController from "./monthly_investment_chart_controller"
import PortfolioAllocationChartController from "./portfolio_allocation_chart_controller"
import PortfolioGrowthChartController from "./portfolio_growth_chart_controller"

application.register("monthly-investment-chart", MonthlyChartController)
application.register("portfolio-allocation-chart", PortfolioAllocationChartController)
application.register("portfolio-growth-chart", PortfolioGrowthChartController)
