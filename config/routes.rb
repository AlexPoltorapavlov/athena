Rails.application.routes.draw do
  devise_for :users

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :admin_panel

  devise_scope :user do
    get 'account', to: 'users/registrations#account'
  end

  # Defines the root path route ("/")
  root 'admin_panel#index'

  telegram_webhook WebhookController, :default


end
