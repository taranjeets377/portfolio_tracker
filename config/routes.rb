Rails.application.routes.draw do
  root "dashboard#index"

  devise_for :users

  resources :stocks
  resources :stock_transactions, path: "transactions", as: "transactions"

  get "dashboard/index"
end
