Rails.application.routes.draw do
  devise_for :users

  resources :rooms, only: :index do
    resources :schedule_items, only: [:index, :show]
  end

  resources :user do
    resources :reservations
  end

  namespace 'admin' do
    resources :schedule_items
  end

  root to: 'rooms#index'
end
