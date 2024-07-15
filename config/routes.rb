Rails.application.routes.draw do
  devise_for :users

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  devise_scope :user do
    get 'account' => 'users/registrations#account'
  end

  # Defines the root path route ("/")
  root 'home#index'

  controller :admins do
    get :admin_panel
    get :new_user
    get :edit_user
    post :create_user
    patch :update_user
    delete :destroy_user
  end

  telegram_webhook WebhookController
end
