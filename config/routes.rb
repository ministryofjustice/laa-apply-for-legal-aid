Rails.application.routes.draw do

  namespace 'v1' do
    resources :status, only: [:index]
    resources :applications, only: [:create]
  end

end
