class EntraIdToken < ApplicationRecord
  belongs_to :provider

  encrypts :access_token
  encrypts :refresh_token
  encrypts :id_token

  def self.store!(user, credentials:)
    token = user.entra_id_token || user.build_entra_id_token

    token.update!(
      access_token: credentials.token,
      refresh_token: credentials.refresh_token,
      id_token: credentials.id_token,
      scope: credentials.scope,
      expires_at: credentials.expires_in&.seconds&.from_now || 1.hour.from_now, # Default to 1 hour if no expiry provided
    )
  end

  def refresh_token!(credentials:)
    update!(
      refresh_token: credentials.refresh_token,
      expires_at: credentials.expires_in&.seconds&.from_now || 1.hour.from_now, # Default to 1 hour if no expiry provided
    )
  end
end
