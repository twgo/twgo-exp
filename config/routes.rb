Rails.application.routes.draw do
  # devise_for :users, ActiveAdmin::Devise.config
  # ActiveAdmin.routes(self)

  root to: "rounds#index"

  resources :githubs, only: [:update, :index]
  resources :ggithubs, only: [:update, :index]

  patch 'githubs', to: 'githubs#update'
  patch 'ggithubs', to: 'ggithubs#update'

  resources :rounds, only: [:update, :index] do
    collection do
      get 'refresh'
      get 'answer'
      get 'best'
      get 'utt'
      get 'audio'
      get 'run_next'
    end
  end

  require 'sidekiq/web'
  mount Sidekiq::Web => '/s'
end
