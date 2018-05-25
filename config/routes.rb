Rails.application.routes.draw do
  # devise_for :users, ActiveAdmin::Devise.config
  # ActiveAdmin.routes(self)

  root to: "rounds#index"

  resources :githubs, only: [:update, :index]

  patch 'githubs', to: 'githubs#update'

  resources :rounds, only: [:update, :index] do
    collection do
      get 'refresh'
      get 'answer'
      get 'best'
      get 'audio'
    end
  end
end
