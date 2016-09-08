Rails.application.routes.draw do
  root 'dashboard#index'
  resources :klasses
  resources :subjects
  resources :app_forms do
    resources :answers
  end

  get 'setup', to: 'setup#index'
  post 'setup/:action', controller: 'setup'
end
