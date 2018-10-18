Rails.application.routes.draw do
  resources :status, only: [:index]

  namespace 'v1' do
    resources :crypt, only: [:create]
    resources :proceeding_types, only: [:index]
    resources :applications, only: %i[create show] do
      resource :applicant, only: %i[create update]
    end
    resources :applicants, only: [:show]
  end
end
