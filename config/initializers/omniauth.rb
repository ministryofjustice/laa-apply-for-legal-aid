require Rails.root.join 'app/lib/omniauth/omniauth_true_layer'
require Rails.root.join 'app/controllers/applicants/omniauth_callbacks_controller.rb'

OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :true_layer,
    ENV['TRUE_LAYER_CLIENT_ID'],
    ENV['TRUE_LAYER_CLIENT_SECRET'],
    scope: 'info accounts balance transactions'
  )
  provider(
    :google_oauth2,
    ENV['GOOGLE_CLIENT_ID'],
    ENV['GOOGLE_CLIENT_SECRET']
  )
end
