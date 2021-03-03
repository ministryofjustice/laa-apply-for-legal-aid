require Rails.root.join 'app/lib/omni_auth/omni_auth_true_layer'
require Rails.root.join 'app/controllers/applicants/omniauth_callbacks_controller.rb'

OmniAuth.config.allowed_request_methods = %i[post get]
OmniAuth.config.logger = Rails.logger
# normally in dev mode, if the user fails to authenticate, an excesption is raised.
# This block here makes sure that dev behaviour is the same as production, i.e.
# is redirectied to /auth/failure
#
OmniAuth.config.on_failure = proc do |env|
  Sentry.capture_message("Omniauth error: #{env['omniauth.error']} and message: #{env['omniauth.error']&.error_reason}")
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
end

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
