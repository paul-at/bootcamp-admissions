Rails.application.routes.draw do
  resources :klasses
  resources :subjects
  resources :app_forms do
    resources :answers
  end
end
