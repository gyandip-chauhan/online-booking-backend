Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'showtimes#index' 

  resources :movies, only: [:index] do
    resources :ratings, only: [:new, :create]
    member do
      post 'rate'
    end
  end

  resources :showtimes do
    resources :bookings, only: [:new, :create]
    member do
      post 'book_now'
      post 'select_seat'
      get 'invoice'
    end
  end

  resources :bookings, only: [:show] do
    member do
      get 'versions'
    end
  end

  resources :theaters, only: [:index] do
    resources :ratings, only: [:new, :create]
    member do
      post 'rate'
    end
  end
end
