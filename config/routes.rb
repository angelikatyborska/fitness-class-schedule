Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords',
    confirmations: 'users/confirmations'
  }

  resources :trainers, only: [:index]
  resources :rooms, only: [:index]

  resources :schedule_items, only: [:index, :show] do
    member do
      get :focus
    end
  end

  resources :user do
    resources :reservations
  end

  namespace 'admin' do
    resources :schedule_items
    resources :fitness_classes, except: :show
    resources :reservations, only: [:new, :create, :update, :destroy]
    resources :trainers, except: :show
    resources :rooms, except: :show  do
      resources :room_photos, only: [:new, :create, :destroy]
    end
  end

  root to: 'schedule_items#index'
end
