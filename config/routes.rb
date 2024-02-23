Rails.application.routes.draw do
  root to: redirect('/admin')

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  get 'up' => 'rails/health#show', as: :rails_health_check

  post '/webhook', to: 'webhooks#create'
  get '/webhook', to: 'webhooks#show'

  namespace :api do
    post 'inventory/sync', to: 'products#sync'
  end
end
