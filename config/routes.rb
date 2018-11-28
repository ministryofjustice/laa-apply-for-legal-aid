Rails.application.routes.draw do
  root to: 'home#index'

  devise_for :providers, controllers: { saml_sessions: 'saml_sessions' }
  devise_for :users
  devise_for :applicants, controllers: { omniauth_callbacks: 'applicants/omniauth_callbacks' }

  resources :status, only: [:index]

  namespace 'v1' do
    resources :proceeding_types, only: [:index]
    resources :applications, only: %i[create show] do
      resource :applicant, only: %i[create update]
    end
    resources :applicants, only: [:show] do
      resources :addresses, only: [:create]
    end
  end

  namespace :citizens do
    resources :legal_aid_applications, only: [:show]
    resource :consent, only: [:show]
    resource :information, only: [:show]
    resources :accounts, only: [:index]
    resources :additional_accounts, only: %i[index create new update]
  end

  namespace :providers do
    root to: 'start#index'

    resources :legal_aid_applications, path: 'applications', only: %i[index new create] do
      resource :applicant, only: %i[show update]

      resources :check_provider_answers, only: [:index] do
        post :confirm, on: :collection
      end
      resource :address, only: %i[edit update]
      resource :address_lookups, only: %i[new create]
      resource :address_selections, only: %i[edit update]
      resource :email, only: %i[show update]
      resources :check_benefits, only: [:index]
    end
  end
end
