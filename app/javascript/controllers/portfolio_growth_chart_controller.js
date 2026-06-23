import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

// Connects to data-controller="portfolio-growth-chart"
export default class extends Controller {
  static values = { data: Array }

  connect() {
    if (!this.dataValue || this.dataValue.length === 0) return

    const labels = this.dataValue.map((point) => point.month)
    const values = this.dataValue.map((point) => point.total_invested)
    const olive = "#9db46b"
    const oliveFill = "rgba(157, 180, 107, 0.16)"
    const mutedText = "#a5b19d"
    const gridLine = "rgba(157, 180, 107, 0.12)"

    const ctx = this.element.getContext("2d")

    if (!ctx) {
      console.log("Canvas context missing")
      return
    }

    new Chart(ctx, {
      type: "line",
      data: {
        labels: labels,
        datasets: [{
          label: "Monthly Capital Deployed (₹)",
          data: values,
          borderColor: olive,
          backgroundColor: oliveFill,
          pointBackgroundColor: olive,
          pointBorderColor: "#090d0b",
          pointHoverBackgroundColor: "#c7db8c",
          pointHoverBorderColor: "#090d0b",
          tension: 0.3,
          fill: true
        }]
      },
      options: {
        maintainAspectRatio: false,
        plugins: {
          legend: {
            labels: {
              color: mutedText
            }
          }
        },
        scales: {
          x: {
            ticks: {
              color: mutedText
            },
            grid: {
              color: gridLine
            }
          },
          y: {
            ticks: {
              color: mutedText
            },
            grid: {
              color: gridLine
            }
          }
        }
      }
    })
  }
}
