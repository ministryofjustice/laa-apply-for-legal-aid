Rails.application.routes.draw do
  get "ping", to: "status#ping", format: :json
  get "healthcheck", to: "status#status", format: :json
  get "status", to: "status#ping", format: :json
  get "data", to: "status#data"

  match "(*any)", to: "pages#servicedown", via: :all if Rails.application.config.x.maintenance_mode

  root to: "providers/start#index"

  require "sidekiq/web"
  require "sidekiq-status/web"
  mount Sidekiq::Web => "/sidekiq"

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == "sidekiq" && password == ENV["SIDEKIQ_WEB_UI_PASSWORD"].to_s
  end

  get "/saml/auth" => "saml_idp#new"
  post "/saml/auth" => "saml_idp#create"

  devise_for :providers, controllers: { saml_sessions: "saml_sessions" }
  devise_for :applicants
  devise_for :admin_users, controllers: { sessions: "admin_users/sessions" }

  devise_scope :applicant do
    match(
      "auth/true_layer/callback",
      to: "applicants/omniauth_callbacks#true_layer",
      via: %i[get puts],
      as: :applicant_true_layer_omniauth_callback,
    )
  end

  devise_scope :admin_user do
    match(
      "auth/google_oauth2/callback",
      to: "admin_users/omniauth_callbacks#google_oauth2",
      via: %i[get puts],
      as: :admin_user_google_oauth2_omniauth_callback,
    )
  end

  get "auth/failure", to: "auth#failure"

  resource :contact, only: [:show]
  resources :accessibility_statement, only: [:index]
  resources :privacy_policy, only: [:index]
  resources :feedback, only: %i[new create show]
  resources :errors, only: [:show], path: :error
  resources :problem, only: :index

  namespace :admin do
    root to: "legal_aid_applications#index"
    post "search", to: "legal_aid_applications#search", as: "application_search"
    namespace :legal_aid_applications do
      resources :submissions, only: [:show] do
        member do
          get "download_xml_response"
          get "download_xml_request"
          get "download_means_report"
          get "download_merits_report"
        end
      end
    end
    resources :legal_aid_applications, only: %i[index destroy] do
      post :create_test_applications, on: :collection
      delete :destroy_all, on: :collection
    end
    resource :settings, only: %i[show update]
    resources :ccms_queues, only: %i[index show] do
      member do
        get "reset_and_restart"
        get "restart_current_submission"
      end
    end
    resource :submitted_applications_report, only: %i[show]
    resource :feedback, controller: :feedback, only: %i[show]
    resources :reports, only: %i[index create]
    get "user_dashboard", to: "user_dashboard#index", as: "user_dashboard"
    resources :roles, only: %i[index]
    namespace :roles do
      resources :permissions, only: %i[show update]
    end
    resources :providers, only: %i[new create]
    resources :firms, only: :index do
      resources :providers, only: :index
    end

    post "provider/check", to: "providers#check", as: "provider_check"
    get "admin_report_application_details", to: "reports#download_application_details_report", as: "application_details_csv"
    get "admin_report_provider_emails", to: "reports#download_provider_emails_report", as: "provider_emails_csv"
    get "admin_report_user_feedbacks", to: "reports#download_user_feedbacks_report", as: "user_feedbacks_csv"
  end

  namespace "v1" do
    resources :legal_aid_applications, only: [:destroy]
    resources :workers, only: [:show]
    resources :statement_of_cases, only: [:create]
    resources :bank_statements, only: [:create]
    resources :uploaded_evidence_collections, only: [:create]
    resources :providers, only: [:update]
    namespace :partners do
      resources :bank_statements, only: [:create]
    end
  end

  namespace :citizens do
    resources :legal_aid_applications, only: %i[show index]
    resources :resend_link_requests, only: %i[show update], path: "resend_link"
    resource :consent, only: %i[show update]
    resource :contact_provider, only: [:show]
    resources :banks, only: %i[index create]
    resources :accounts, only: [:index]
    resources :gather_transactions, only: [:index]
    resources :additional_accounts, only: %i[index create new update]
    resources :check_answers, only: [:index] do
      patch :reset, on: :collection
      patch :continue, on: :collection
    end
    resource :means_test_result, only: [:show]
  end

  namespace :providers do
    root to: "start#index"
    resource :provider, only: [:show], path: "your_profile"
    resources :applicants, only: %i[new create]
    resource :confirm_office, only: %i[show update]
    resource :select_office, only: %i[show update]
    resource :declaration, only: %i[show]
    resource :invalid_login, only: :show
    resources :cookies, only: %i[show update]

    resources :legal_aid_applications, path: "applications", only: %i[index create] do
      namespace :means do
        resource :cash_outgoing, only: %i[show update]
        resource :full_employment_details, only: %i[show update]
        resource :employment_income, only: %i[show update]
        resource :unexpected_employment_income, only: %i[show update]
        resource :student_finance, only: %i[show update]
        resource :cash_income, only: %i[show update]
        resource :regular_incomes, only: %i[show update]
        resource :regular_outgoings, only: %i[show update]
        resource :housing_benefits, only: %i[show update]
        resource :identify_types_of_income, only: %i[show update]
        resource :identify_types_of_outgoing, only: %i[show update]
        resource :has_dependants, only: %i[show update]
        resources :dependants, only: %i[new show update]
        resources :remove_dependants, only: %i[show update]
        resource :has_other_dependants, only: %i[show update]
        resource :own_home, only: %i[show update]
        resource :property_details, only: %i[show update]
        resource :vehicle, only: %i[show update]
        resources :vehicle_details, only: %i[show new update]
        resource :add_other_vehicles, only: %i[show update]
        resources :remove_vehicles, only: %i[show update]
        resource :savings_and_investment, only: %i[show update]
        resource :other_assets, only: %i[show update]
        resource :restrictions, only: %i[show update]
        resource :policy_disregards, only: %i[show update]
        resource :check_income_answers, only: %i[show update]
        resource :add_other_state_benefits, only: %i[show update]
        resources :state_benefits, only: %i[new show update]
        resource :receives_state_benefits, only: %i[show update]
        resources :remove_state_benefits, only: %i[show update]
      end
      get :search, on: :collection
      namespace :correspondence_address do
        resource :choice, only: %i[show update], path: "where_to_send_correspondence"
        resource :care_of, only: %i[show update], path: "care_of_recipient"
        resource :lookup, only: %i[show update], path: "find_correspondence_address"
        resource :manual, only: %i[show update], path: "enter_correspondence_address"
        resource :selection, only: %i[show update], path: "correspondence_address_results"
      end
      namespace :home_address do
        resource :status, only: %i[show update]
        resource :lookup, only: %i[show update], path: "find_home_address"
        resource :manual, only: %i[show update], path: "enter_home_address"
        resource :non_uk_home_address, only: %i[show update]
        resource :selection, only: %i[show update], path: "home_address_results"
      end
      namespace :link_application do
        resource :make_link, only: %i[show update]
        resource :find_link_application, only: %i[show update], path: "find_link_case"
        resource :confirm_link, only: %i[show update]
        resource :copy, only: %i[show update]
      end
      resource :delete, controller: :delete, only: %i[show destroy]
      resources :proceedings_types, only: %i[index create]
      resource :has_other_proceedings, only: %i[show update destroy]
      resource :limitations, only: %i[show update]
      resource :applicant_details, only: %i[show update]
      resource :check_benefit, only: %i[index update]
      resource :has_national_insurance_number, only: %i[show update]
      resources :check_benefits, only: [:index]
      resources :applicant_employed, only: %i[index create]
      resource :about_financial_means, only: %i[show update]
      resource :open_banking_consents, only: %i[show update], path: "does-client-use-online-banking"
      resource :open_banking_guidance, only: %i[show update]
      resource :bank_statements, only: %i[show update destroy] do
        get "/list", to: "bank_statements#list"
      end
      resource :capital_introduction, only: %i[show update]
      resources :check_provider_answers, only: [:index] do
        post :reset, on: :collection
        patch :continue, on: :collection
      end
      resource :about_the_financial_assessment, only: %i[show update]
      resource :email_address, only: %i[show update]
      resource :application_confirmation, only: :show
      resource :applicant_bank_account, only: %i[show update]
      resource :offline_account, only: %i[show update]
      resource :check_passported_answers, only: [:show] do
        patch :continue
        patch :reset
      end
      resource :capital_assessment_result, only: %i[show update]
      resource :capital_income_assessment_result, only: %i[show update]
      resource :date_client_told_incident, only: %i[show update], controller: "application_merits_task/date_client_told_incidents"
      resource :client_denial_of_allegation, only: %i[show update], controller: "application_merits_task/client_denial_of_allegations"
      resource :client_offered_undertakings, only: %i[show update], controller: "application_merits_task/client_offered_undertakings"
      resource :in_scope_of_laspo, only: %i[show update], controller: "application_merits_task/in_scope_of_laspos"
      resource :nature_of_urgencies, only: %i[show update], controller: "application_merits_task/nature_of_urgencies"
      resource :merits_task_list, only: %i[show update]

      resource :uploaded_evidence_collection, only: %i[show update destroy] do
        get "/list", to: "uploaded_evidence_collections#list"
      end
      resource :check_merits_answers, only: [:show] do
        patch :continue
        patch :reset
      end

      resource :client_completed_means, only: %i[show update]
      resources :income_summary, only: %i[index create]
      resources :outgoings_summary, only: %i[index create]
      resource :incoming_transactions, only: [] do
        get "/:transaction_type", to: "incoming_transactions#show", as: ""
        patch "/:transaction_type", to: "incoming_transactions#update"
      end
      resource :outgoing_transactions, only: [] do
        get "/:transaction_type", to: "outgoing_transactions#show", as: ""
        patch "/:transaction_type", to: "outgoing_transactions#update"
      end
      resources :bank_transactions, only: [] do
        patch "remove_transaction_type", on: :member
      end
      resource :check_capital_answers, only: %i[show update]

      resource :use_ccms, only: %i[show]
      resources :use_ccms_employment, only: %i[index]
      resource :use_ccms_under16s, only: %i[show]
      resource :no_national_insurance_number, only: %i[show update]
      resource :substantive_application, only: %i[show update]
      resource :end_of_application, only: %i[show update]
      resource :submitted_application, only: :show
      resources :delegated_confirmation, only: :index
      resource :merits_report, only: :show
      resource :means_report, only: :show
      resource :confirm_dwp_non_passported_applications, only: %i[show update]
      resource :confirm_non_means_tested_applications, only: %i[show update]
      resource :check_client_details, only: %i[show update]
      resource :received_benefit_confirmation, only: %i[show update]
      resource :has_evidence_of_benefit, only: %i[show update]
      resource :confirm_client_declaration, only: %i[show update]
      resource :review_and_print_application, only: [:show] do
        patch :continue
        patch :reset
      end
      scope module: :interrupt do
        resource :block, only: %i[show], path: "voided-application"
      end

      scope module: :proceedings_sca do
        get "/interrupt/:type", to: "interrupts#show", as: "sca_interrupt"
        resource :proceeding_issue_statuses, only: %i[show update], path: "proceeding_issue_status"
        resource :heard_togethers, only: %i[show update], path: "will_proceedings_be_heard_together"
        resource :supervision_orders, only: %i[show update], path: "supervision_order_changes"
        resource :child_subject, only: %i[show update], path: "client_is_child_subject"
        resource :heard_as_alternatives, only: %i[show update], path: "will_proceeding_be_heard_as_an_alternative"
        resource :change_of_names, only: %i[show update]
      end
      scope module: :proceeding_loop do
        resources :delegated_functions, only: %i[show update]
        resources :confirm_delegated_functions_date, only: %i[show update]
        resources :client_involvement_type, only: %i[show update]
        resources :substantive_defaults, only: %i[show update]
        resources :emergency_defaults, only: %i[show update]
        resources :substantive_level_of_service, only: %i[show update]
        resources :emergency_level_of_service, only: %i[show update]
        resources :substantive_scope_limitations, only: %i[show update]
        resources :emergency_scope_limitations, only: %i[show update]

        resource :final_hearings, only: [] do
          get "/:id/:work_type", to: "final_hearings#show", as: ""
          patch "/:id/:work_type", to: "final_hearings#update"
        end
      end

      scope module: :partners do
        resource :client_has_partner, only: %i[show update]
        resource :contrary_interest, only: %i[show update]
      end

      namespace :partners do
        resource :details, only: %i[show update]
        resource :about_financial_means, only: %i[show update]
        resources :employed, only: %i[index create]
        resources :use_ccms_employment, only: %i[index]
        resource :employment_income, only: %i[show update]
        resource :unexpected_employment_income, only: %i[show update]
        resource :full_employment_details, only: %i[show update]
        resource :student_finance, only: %i[show update]
        resource :regular_outgoings, only: %i[show update]
        resource :cash_outgoing, only: %i[show update]
        resource :bank_statements, only: %i[show update destroy] do
          get "/list", to: "bank_statements#list"
        end
        resource :bank_accounts, only: %i[show update]
        resource :receives_state_benefits, only: %i[show update]
        resources :state_benefits, only: %i[new show update]
        resource :add_other_state_benefits, only: %i[show update]
        resources :remove_state_benefits, only: %i[show update]
        resource :regular_incomes, only: %i[show update]
        resource :cash_income, only: %i[show update]
      end

      scope module: :application_merits_task do
        resources :involved_children, only: %i[new show update]
        resources :remove_involved_child, only: %i[show update]

        resources :opponent_individuals, only: %i[new show update]
        resources :opponent_new_organisations, only: %i[new show update]
        resources :opponent_existing_organisations, only: %i[index create]
        resources :remove_opponent, only: %i[show update]

        resource :client_denial_of_allegation, only: %i[show update]
        resource :client_offered_undertakings, only: %i[show update]
        resource :date_client_told_incident, only: %i[show update]
        resource :has_other_involved_children, only: %i[show update]
        resource :in_scope_of_laspo, only: %i[show update]
        resource :has_other_opponent, only: %i[new show update]
        resource :opponent_type, only: %i[show update]
        resource :opponents_mental_capacity, only: %i[show update]
        resource :domestic_abuse_summary, only: %i[show update]
        resource :matter_opposed_reason, only: %i[show update]
        resource :nature_of_urgencies, only: %i[show update]
        resource :statement_of_case, only: %i[show update destroy] do
          get "/list", to: "statement_of_cases#list"
        end
      end
    end

    resources :merits_task_list, only: [] do
      scope module: :proceeding_merits_task do
        resources :chances_of_success, only: %i[index create]

        resource :attempts_to_settle, only: %i[show update], controller: "attempts_to_settle"
        resource :linked_children, only: %i[show update]
        resource :opponents_application, only: %i[show update], controller: "opponents_application"
        resource :prohibited_steps, only: %i[show update]
        resource :specific_issue, only: %i[show update], controller: "specific_issue"
        resource :success_prospects, only: %i[show update]
        resource :vary_order, only: %i[show update], controller: "vary_order"
      end
    end
  end

  # dummy route to set session vars available in test environment only
  if Rails.env.test?
    namespace :test do
      resource :session, only: %i[create]
    end
  end

  get "/submission_feedback/:application_ref", to: "feedback#submission"
  get "test/trapped_error", to: "test/generate_error#trapped_error"
  get "test/untrapped_error", to: "test/generate_error#untrapped_error"

  get "/.well-known/security.txt" => redirect("https://raw.githubusercontent.com/ministryofjustice/security-guidance/master/contact/vulnerability-disclosure-security.txt")

  # Catch all route that traps paths not defined above. Must be last route.
  match "*path", to: "errors#page_not_found", via: :all
end
