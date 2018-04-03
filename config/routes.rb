Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # root to: "admin/dashboard#index"

  root to: "rounds#index"

  get '/editor', to: 'static#editor'
  patch '/editor', to: 'static#update'

  resources :rounds do
    collection do
      get 'refresh'
    end
  end
end
