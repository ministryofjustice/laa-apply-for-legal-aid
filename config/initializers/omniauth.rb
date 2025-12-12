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
  omniauth_error_type = env["omniauth.error.type"]

  AlertManager.capture_message("Omniauth error: #{omniauth_error}")

  provider_error = omniauth_error.respond_to?(:error) ? omniauth_error.error : "unknown_error"
  provider_error_reason = omniauth_error.respond_to?(:reason) ? omniauth_error.reason : nil
  provider_error_message = omniauth_error.respond_to?(:message) ? omniauth_error.message : nil
  provider_error_desc = omniauth_error.respond_to?(:error_description) ? omniauth_error.error_description : nil
  provider_error_uri = omniauth_error.respond_to?(:error_uri) ? omniauth_error.error_uri : nil
  provider_error_wrapped = omniauth_error.respond_to?(:wrapped_exception) ? omniauth_error.wrapped_exception : nil

  Rails.logger.warn("Omniauth error type: #{omniauth_error_type || 'none'}")
  Rails.logger.warn("  error: #{omniauth_error}")
  Rails.logger.warn("  provider error: #{provider_error || 'none'}")
  Rails.logger.warn("  reason: #{provider_error_reason || 'none'}")
  Rails.logger.warn("  message: #{provider_error_message || 'none'}")
  Rails.logger.warn("  description: #{provider_error_desc || 'none'}")
  Rails.logger.warn("  uri: #{provider_error_uri || 'none'}")
  Rails.logger.warn("  wrapped: #{provider_error_wrapped || 'none'}")

  Rails.logger.warn("  error: #{omniauth_error.class}")

  if omniauth_error.class.is_a? Hash
    Rails.logger.warn("  error hash keys: #{omniauth_error.keys.join(', ')}")
    Rails.logger.warn("  error error: #{omniauth_error['error'] || 'none'}")
    Rails.logger.warn("  error error (sym): #{omniauth_error[:error] || 'none'}")
    Rails.logger.warn("  error reason: #{omniauth_error['reason'] || 'none'}")
    Rails.logger.warn("  error reason (sym): #{omniauth_error[:reason] || 'none'}")
    Rails.logger.warn("  error message: #{omniauth_error['message'] || 'none'}")
    Rails.logger.warn("  error message (sym): #{omniauth_error[:message] || 'none'}")
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
