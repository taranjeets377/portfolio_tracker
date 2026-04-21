import "@hotwired/turbo"
import "./controllers"
import Chart from "chart.js/auto"

// Make Chart global so all controllers can access it
window.Chart = Chart
