Rails.application.routes.draw do
  resource :session, only: [:new, :create, :destroy]
  resource :profile, only: [:edit, :update]
  resources :tasks
  root to: "tasks#index"
end
