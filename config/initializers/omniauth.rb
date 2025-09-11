Rails.application.reloader.to_prepare do
  require Rails.root.join "app/lib/omni_auth/omni_auth_true_layer"
  require Rails.root.join "app/controllers/applicants/omniauth_callbacks_controller.rb"
end

OmniAuth.config.allowed_request_methods = %i[post get]
OmniAuth.config.silence_get_warning = true # Warnings silenced for now.  See ticket AP-2098 for attempts to resolve this
OmniAuth.config.logger = Rails.logger

# Normally in dev mode if the user fails to authenticate an exception is raised.
# This block here makes sure that dev behaviour is the same as production, i.e.
# is redirected to /auth/failure.
#
OmniAuth.config.on_failure = proc do |env|
  AlertManager.capture_message("Omniauth error: #{env['omniauth.error']} and message: #{env['omniauth.error']}")
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :true_layer,
    Rails.configuration.x.true_layer.client_id,
    Rails.configuration.x.true_layer.client_secret,
    scope: "info accounts balance transactions",
  )
  provider(
    :google_oauth2,
    Rails.configuration.x.google_oauth2.client_id,
    Rails.configuration.x.google_oauth2.client_secret,
  )
  provider(
    :openid_connect,
    {
      name: :entra_id,
      scope: %i[openid email],
      prompt: :select_account,
      response_type: :code,
      send_nonce: true,
      client_options: {
        identifier: ENV.fetch("OMNIAUTH_ENTRAID_CLIENT_ID", nil),
        secret: ENV.fetch("OMNIAUTH_ENTRAID_CLIENT_SECRET", nil),
        redirect_uri: ENV.fetch("OMNIAUTH_ENTRAID_REDIRECT_URI", nil),
      },
      discovery: true,
      pkce: true,
      issuer: "https://login.microsoftonline.com/#{ENV.fetch('OMNIAUTH_ENTRAID_TENANT_ID', nil)}/v2.0",
      strategy_class: OmniAuth::Strategies::Silas,
    },
  )
  provider(
    :openid_connect,
    {
      name: :admin_entra_id,
      scope: %i[openid email],
      response_type: :code,
      client_options: {
        identifier: ENV.fetch("ADMIN_OMNIAUTH_ENTRAID_CLIENT_ID", nil),
        secret: ENV.fetch("ADMIN_OMNIAUTH_ENTRAID_CLIENT_SECRET", nil),
        redirect_uri: ENV.fetch("ADMIN_OMNIAUTH_ENTRAID_REDIRECT_URI", nil),
      },
      discovery: true,
      pkce: true,
      issuer: "https://login.microsoftonline.com/#{ENV.fetch('ADMIN_OMNIAUTH_ENTRAID_TENANT_ID', nil)}/v2.0",
      extra_authorise_params: { tenant: ENV.fetch("ADMIN_OMNIAUTH_ENTRAID_TENANT_ID", nil) },
    },
  )
end
