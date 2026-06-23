import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

// Connects to data-controller="portfolio-allocation-chart"
export default class extends Controller {
  static values = { data: Array }

  connect() {
    if (!this.dataValue || this.dataValue.length === 0) return

    const labels = this.dataValue.map((holding) => holding.symbol)
    const values = this.dataValue.map((holding) => holding.allocation_percentage)
    const palette = [
      "#9db46b",
      "#c7db8c",
      "#7dd87f",
      "#6f8f4f",
      "#b7c978",
      "#d6e5a3",
      "#86a35a",
      "#a5b19d"
    ]
    const mutedText = "#a5b19d"

    const ctx = this.element.getContext("2d")

    if (!ctx) {
      console.log("Canvas context missing")
      return
    }

    new Chart(ctx, {
      type: "pie",
      data: {
        labels: labels,
        datasets: [{
          label: "Allocation (%)",
          data: values,
          backgroundColor: labels.map((_, index) => palette[index % palette.length]),
          borderColor: "#090d0b",
          borderWidth: 2,
          hoverOffset: 8
        }]
      },
      options: {
        maintainAspectRatio: false,
        plugins: {
          title: {
            display: true,
            text: "Portfolio Allocation",
            color: "#f4f7ef",
            font: {
              size: 16,
              weight: "bold"
            }
          },
          legend: {
            position: "bottom",
            labels: {
              color: mutedText,
              boxWidth: 14,
              padding: 18
            }
          },
          tooltip: {
            callbacks: {
              label: (context) => `${context.label}: ${context.parsed.toFixed(2)}%`
            }
          }
        }
      }
    })
  }
}
