Rails.application.routes.draw do
  root 'dashboard#index'
  resources :klasses
  resources :subjects
  resources :app_forms do
    resources :answers
  end
end
