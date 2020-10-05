class Debug < ApplicationRecord
  # :nocov:
  def self.record_request(session, auth_params, callback_url)
    create!(
      debug_type: 'request',
      legal_aid_application_id: session[:current_application_id],
      session_id: session[:session_id],
      session: session.to_h.to_json,
      auth_params: auth_params.to_json,
      callback_url: callback_url
    )
  end

  def self.record_callback(session, callback_params)
    create!(
      debug_type: 'callback',
      legal_aid_application_id: session[:current_application_id],
      session_id: session[:session_id],
      session: session.to_h.to_json,
      callback_params: callback_params.to_json
    )
  end

  def self.record_error(session, params, details)
    create!(
      debug_type: 'error',
      legal_aid_application_id: session[:current_application_id],
      session_id: session[:session_id],
      session: session.to_h.to_json,
      callback_params: params.to_json,
      error_details: details
    )
  end
  # :nocov:
end
