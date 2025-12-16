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
  omniauth_error = env["omniauth.error"]

  # NOTE: do not bother to alert on CSRF state mismatch errors - these are common and
  # usually caused by various user and client browser behaviours. Session timeout during callback,
  # browser privacy features, multi tab logins, and bots are common causes.
  if omniauth_error.to_s.include?("Invalid 'state' parameter")
    Rails.logger.warn("Omniauth CSRF state mismatch error: #{omniauth_error}")
  else
    Rails.logger.warn("Omniauth error: #{omniauth_error}")
    AlertManager.capture_exception(omniauth_error)
  end

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
      prompt: :select_account,
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
