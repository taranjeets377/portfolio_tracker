Rails.application.routes.draw do
  root "dashboard#index"

  devise_for :users

  resources :stocks
  resources :stock_transactions, path: "transactions", as: "transactions"
  resources :dividend_receipts, path: "dividends", as: "dividends"
  resources :dividend_receipts, path: "dividends", only: [:index, :new, :create]

  get "dashboard/index"
end
