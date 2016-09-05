Rails.application.routes.draw do
  resources :app_forms do
    resources :answers
  end
end
