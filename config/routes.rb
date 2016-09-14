Rails.application.routes.draw do
  devise_for :users
  root 'dashboard#index'
  resources :klasses
  resources :subjects
  resources :app_forms
  get 'administrators', to: 'administrators#index'
  post 'administrators/(:id)', to: 'administrators#update'

  get 'setup', to: 'setup#index'
  # http://stackoverflow.com/questions/37008713/rails-5-1-routes-dynamic-action-parameters
  post 'setup/fake', to: 'setup#fake'
end
