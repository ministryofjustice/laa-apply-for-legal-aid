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
    resource :property_value, only: %i[show update]
    resource :information, only: [:show]
    resources :accounts, only: [:index]
    resources :additional_accounts, only: %i[index create new update]
    resource :own_home, only: %i[show update]
    resource :percentage_home, only: %i[show update]
    resource :outstanding_mortgage, only: %i[show update]
    resource :savings_and_investment, only: %i[show update]
    resource :shared_ownership, only: %i[show update]
    resources :restrictions, only: %i[index create] # as multiple restrictions
    resource :other_assets, only: %i[show update]
  end

  namespace :providers do
    root to: 'start#index'

    resources :legal_aid_applications, path: 'applications', only: %i[index create] do
      resource :proceedings_type, only: %i[show update]
      resource :property_value, only: %i[show update]
      resource :applicant, only: %i[show update]
      resource :address, only: %i[show update]
      resource :address_lookup, only: %i[show update]
      resource :address_selection, only: %i[show update]
      resource :own_home, only: %i[show update]
      resources :check_benefits, only: [:index]
      resource :online_banking, only: %i[show update], path: 'does-client-use-online-banking'
      resources :check_provider_answers, only: [:index] do
        post :reset, on: :collection
        post :continue, on: :collection
      end
      resources :restrictions, only: %i[index create] # as multiple restrictions
      resource :about_the_financial_assessment, only: [:show] do
        post :submit, on: :collection
      end
      resource :percentage_home, only: %i[show update]
    end
  end
end
