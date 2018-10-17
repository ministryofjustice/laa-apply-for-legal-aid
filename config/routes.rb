Rails.application.routes.draw do

  root to: 'home#index'

  resources :status, only: [:index]

  namespace 'v1' do
    resources :proceeding_types, only: [:index]
    resources :applications, only: %i[create show] do
      resource :applicant, only: %i[create update]
    end
    resources :applicants, only: [:show]
  end

  namespace :provider do
    resources :legal_aid_applications, path: 'laa' do
      resource :applicant
    end
  end
end
