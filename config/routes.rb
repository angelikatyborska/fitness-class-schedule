Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords'
  }

  resources :trainers, only: [:index]

  resources :rooms, only: [:index, :show] do
    collection do
      get :prev_week
      get :next_week
    end

    resources :schedule_items, only: [:show] do
      collection do
        get :prev_week
        get :next_week
      end
    end
  end

  resources :user do
    resources :reservations
  end

  namespace 'admin' do
    resources :schedule_items, except: :show
    resources :fitness_classes, except: :show
    resources :trainers, except: :show
  end

  root to: 'rooms#index'
end
