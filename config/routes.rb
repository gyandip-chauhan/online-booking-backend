require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  root to: redirect('/admin')
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self) rescue ActiveAdmin::DatabaseHitDuringLoad
  devise_for :users, skip: [:sessions, :registrations], controllers: {
    confirmations: "users/confirmations"
  }
  namespace :internal_api, defaults: { format: "json" } do
    namespace :v1 do
      namespace :users do
        devise_scope :user do
          post "login", to: "sessions#create", as: "login"
          delete "logout", to: "sessions#destroy", as: "logout"
          post "signup", to: "registrations#create", as: "signup"
          post "forgot_password", to: "passwords#create", as: "forgot_password"
          put "reset_password", to: "passwords#update", as: "reset_password"
          post "resend_confirmation_email", to: "confirmations#create", as: "resend_confirmation_email"
        end
      end
      resources :showtimes, only: [:index, :show] do
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

      resources :stripe_payments, only: [:create] do
        collection do
          put 'confirm'
        end
      end

      resources :movies, only: [:index, :show] do
        resources :ratings, only: [:new, :create]
        member do
          post 'rate'
        end
      end
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root 'showtimes#index'
  mount Sidekiq::Web => '/sidekiq'

  resources :movies, only: [:index] do
    resources :ratings, only: [:new, :create]
    member do
      post 'rate'
    end
  end

  resources :showtimes, only: [:index, :show] do
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
      get :filter_data_via_odbc
      get :filter_options_via_odbc
    end
  end
end
