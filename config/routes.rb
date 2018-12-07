Rails.application.routes.draw do
  root to: 'home#index'

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
    resource :consent, only: %i[show create]
    resource :information, only: [:show]
    resources :accounts, only: [:index]
    resources :additional_accounts, only: %i[index create new update]
    resource :own_home, only: %i[show update]
    resource :percentage_home, only: %i[show update]
  end

  namespace :providers do
    root to: 'start#index'

    resources :legal_aid_applications, path: 'applications', only: %i[index create] do
      resource :proceedings_type, only: %i[show update]
      resource :applicant, only: %i[show update]
      resource :address, only: %i[show update]
      resource :address_lookup, only: %i[show update]
      resource :address_selection, only: %i[show update]
      resources :check_benefits, only: [:index] do
        get :passported, on: :collection
      end
      resource :online_banking, only: %i[show update], path: 'does-client-use-online-banking'
      resources :check_provider_answers, only: [:index] do
        post :reset, on: :collection
        post :continue, on: :collection
      end
      resource :about_the_financial_assessment, only: [:show] do
        post :submit, on: :collection
      end
    end
  end
end
