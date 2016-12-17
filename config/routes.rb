Rails.application.routes.draw do
  devise_for :users

  root 'dashboard#index'
  get 'dashboard/user'

  # Application forms
  resources :app_forms do
    resources :scores do
      collection do
        get 'edit', to: 'scores#edit'
      end
    end
    resources :votes do
      collection do
        delete '/', to: 'votes#destroy'
      end
    end
    resources :interview_notes
    resources :attachments
    resources :answers do
      collection do
        patch '/', to: 'answers#update'
      end
    end

    collection do
      get 'deleted', to: 'app_forms#deleted'
      get 'autocomplete'
    end

    member do
      post 'event'
      post 'payment'
      post 'comment'
      post 'delete'
      post 'restore'
    end
  end

  resources :emails do
    collection do
      get 'mergetags', to: 'emails#mergetags'
    end
  end
  resources :subscriptions

  # Settings pages
  resources :klasses
  resources :subjects
  resources :payment_tiers
  resources :email_rules
  resources :email_templates
  get 'administrators', to: 'administrators#index'
  post 'administrators/(:id)', to: 'administrators#update'
  get 'export', to: 'export#index'
  post 'export/app_forms'
  get 'import', to: 'import#index'
  post 'import/import'
  get 'settings', to: 'settings#index'
  post 'settings/update'
  
  get 'setup', to: 'setup#index'
  # http://stackoverflow.com/questions/37008713/rails-5-1-routes-dynamic-action-parameters
  post 'setup/fake', to: 'setup#fake'
end
