require Rails.root.join 'app/lib/omniauth/omniauth_true_layer'
require Rails.root.join 'app/controllers/applicants/omniauth_callbacks_controller.rb'

OmniAuth.config.allowed_request_methods = %i[post get]
OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :true_layer,
    Rails.configuration.x.true_layer.client_id,
    Rails.configuration.x.true_layer.client_secret,
    scope: 'info accounts balance transactions'
  )
  provider(
    :google_oauth2,
    Rails.configuration.x.google_oauth2.client_id,
    Rails.configuration.x.google_oauth2.client_secret
  )
end
