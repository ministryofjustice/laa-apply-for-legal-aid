class EntraIdToken < ApplicationRecord
  belongs_to :provider

  encrypts :access_token
  encrypts :refresh_token
  encrypts :id_token
  encrypts :scope

  def store!(credentials:)
    update!(
      access_token: credentials.access_token || credentials.token,
      access_token_expires_at: credentials.expires_in&.seconds&.from_now || 1.hour.from_now, # Default to 1 hour if no expiry provided
      refresh_token: credentials.refresh_token,
      id_token: credentials.id_token,
      scope: credentials.scope,
    )
  end
end
