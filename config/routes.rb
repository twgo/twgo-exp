Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root to: "admin/dashboard#index"

  get "/index.html" => "static#indexkp"

  resources :static do
    collection do
      get 'download'
    end
  end
end
