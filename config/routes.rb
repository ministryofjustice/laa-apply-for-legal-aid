Rails.application.routes.draw do
  root to: 'home#index'

  require 'sidekiq/web'
  require 'sidekiq-status/web'
  mount Sidekiq::Web => '/sidekiq'

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == 'sidekiq' && password == ENV['SIDEKIQ_WEB_UI_PASSWORD'].to_s
  end

  get '/saml/auth' => 'saml_idp#new'
  post '/saml/auth' => 'saml_idp#create'

  devise_for :providers, controllers: { saml_sessions: 'saml_sessions' }
  devise_for :applicants, controllers: { omniauth_callbacks: 'applicants/omniauth_callbacks' }
  devise_for :admin_users

  resources :status, only: [:index]
  resource :contact, only: [:show]
  resources :feedback, only: %i[new create show]
  resources :errors, only: [:show], path: :error

  namespace :admin do
    root to: 'legal_aid_applications#index'
    resources :legal_aid_applications, only: %i[index destroy] do
      post :create_test_applications, on: :collection
      delete :destroy_all, on: :collection
    end
    resource :settings, only: %i[show update]
  end

  namespace 'v1' do
    resources :proceeding_types, only: [:index]
    resources :workers, only: [:show]
  end

  namespace :citizens do
    resources :legal_aid_applications, only: %i[show index]
    resources :resend_link_requests, only: %i[show update], path: 'resend_link'
    resource :consent, only: %i[show create]
    resource :property_value, only: %i[show update]
    resource :information, only: [:show]
    resources :accounts, only: [:index] do
      get :gather, on: :collection
    end
    resources :additional_accounts, only: %i[index create new update]
    resource :own_home, only: %i[show update]
    resource :percentage_home, only: %i[show update]
    resource :outstanding_mortgage, only: %i[show update]
    resource :savings_and_investment, only: %i[show update]
    resource :shared_ownership, only: %i[show update]
    resources :restrictions, only: %i[index create] # as multiple restrictions
    resource :other_assets, only: %i[show update]
    resources :check_answers, only: [:index] do
      patch :reset, on: :collection
      patch :continue, on: :collection
    end
    resource :identify_types_of_income, only: %i[show update]
    resource :identify_types_of_outgoing, only: %i[show update]
    resources :income_summary, only: :index
    resources :outgoings_summary, only: :index
    resource :incoming_transactions, only: [] do
      get '/:transaction_type', to: 'incoming_transactions#show', as: ''
      patch '/:transaction_type', to: 'incoming_transactions#update'
    end
    resource :outgoing_transactions, only: [] do
      get '/:transaction_type', to: 'outgoing_transactions#show', as: ''
      patch '/:transaction_type', to: 'outgoing_transactions#update'
    end
    resource :means_test_result, only: [:show]
    resource :declaration, only: %i[show update]
  end

  namespace :providers do
    root to: 'start#index' # TODO: In the live app this will point at an external url
    resource :provider, only: [:show], path: 'your_profile'

    resources :legal_aid_applications, path: 'applications', only: %i[index create] do
      resources :proceedings_types, only: %i[index create update destroy]
      resource :property_value, only: %i[show update]
      resource :limitations, only: %i[show update]
      resource :applicant, only: %i[show update]
      resource :address, only: %i[show update]
      resource :address_lookup, only: %i[show update]
      resource :address_selection, only: %i[show update]
      resource :outstanding_mortgage, only: %i[show update]
      resource :own_home, only: %i[show update]
      resource :check_benefit, only: %i[index update]
      resource :other_assets, only: %i[show update]
      resource :statement_of_case, only: %i[show update destroy]
      resources :check_benefits, only: [:index]
      resource :online_banking, only: %i[show update], path: 'does-client-use-online-banking'
      resource :merits_declaration, only: %i[show update]
      resource :capital_introduction, only: %i[show update]
      resources :check_provider_answers, only: [:index] do
        post :reset, on: :collection
        patch :continue, on: :collection
      end
      resources :restrictions, only: %i[index create] # as multiple restrictions
      resource :about_the_financial_assessment, only: %i[show update]
      resource :application_confirmation, only: :show
      resource :percentage_home, only: %i[show update]
      resource :vehicle, only: %i[show create] do
        namespace :vehicles, path: '' do
          resource :estimated_value, only: %i[show update]
          resource :remaining_payments, only: %i[show update]
          resource :purchase_date, only: %i[show update]
          resource :regular_use, only: %i[show update]
        end
      end
      resource :savings_and_investment, only: %i[show update]
      resource :shared_ownership, only: %i[show update]
      resource :check_passported_answers, only: [:show] do
        patch :continue
        patch :reset
      end
      resource :identify_types_of_income, only: %i[show update]
      resource :identify_types_of_outgoing, only: %i[show update]
      resource :respondent, only: %i[show update]
      resource :date_client_told_incident, only: %i[show update]
      resource :details_latest_incident, only: %i[show update]
      resource :client_received_legal_help, only: %i[show update]
      resource :proceedings_before_the_court, only: %i[show update]
      resource :estimated_legal_costs, only: %i[show update]
      resource :success_prospects, only: %i[show update]
      resource :check_merits_answers, only: [:show] do
        patch :continue
        patch :reset
      end
      resource :start_merits_assessment, only: %i[show update]
      resource :client_completed_means, only: %i[show update]
      resources :income_summary, only: %i[index create]
      resources :outgoings_summary, only: %i[index create]
      resource :incoming_transactions, only: [] do
        get '/:transaction_type', to: 'incoming_transactions#show', as: ''
        patch '/:transaction_type', to: 'incoming_transactions#update'
      end
      resource :outgoing_transactions, only: [] do
        get '/:transaction_type', to: 'outgoing_transactions#show', as: ''
        patch '/:transaction_type', to: 'outgoing_transactions#update'
      end
      resources :bank_transactions, only: [] do
        patch 'remove_transaction_type', on: :member
      end
      resource :means_summary, only: %i[show update]
    end
  end
end
