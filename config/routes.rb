Rails.application.routes.draw do
  get 'bonuses/index'
  get 'bonuses/new'
  get 'bonuses/create'
  get 'stock_splits/index'
  root "dashboard#index"

  devise_for :users

  resources :stocks do
    resources :stock_splits, only: [:index, :new, :create]
    resources :bonuses, only: [:index, :new, :create]
  end
  resources :stock_transactions, path: "transactions", as: "transactions"
  resources :dividend_receipts, path: "dividends", as: "dividends"
  resources :dividend_receipts, path: "dividends", only: [:index, :new, :create]

  get "dashboard/index"
end
