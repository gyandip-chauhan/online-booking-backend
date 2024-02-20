require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'showtimes#index'
  mount Sidekiq::Web => '/sidekiq'

  resources :movies, only: [:index] do
    resources :ratings, only: [:new, :create]
    member do
      post 'rate'
    end
  end

  resources :showtimes do
    member do
      post 'book_now'
      post 'select_seat'
    end
  end

  resources :bookings, only: [:index] do
    member do
      get 'invoice'
      get 'cancel'
      get 'versions'
    end
  end

  resources :theaters, only: [:index] do
    resources :ratings, only: [:new, :create]
    member do
      post 'rate'
    end
  end

  resources :events_raws, only: [:index] do
    collection do
      get :filter_options
    end
  end
end
