Rails.application.routes.draw do
  resources :status, only: [:index]
  resources :proceeding_types, only: [:index]

  namespace 'v1' do
    resources :status, only: [:index]
    resources :applications, only: [:create, :show]
    resources :applicants
  end
end
