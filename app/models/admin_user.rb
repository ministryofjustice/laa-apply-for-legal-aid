class AdminUser < ApplicationRecord
  encrypts :auth_subject_uid, deterministic: true

  devise(
    :database_authenticatable, :trackable, :lockable,
    authentication_keys: [:username], unlock_strategy: :time
  )

  def self.from_omniauth(auth)
    # Find by auth.uid if admin has previously logged in with entra, else email
    admin = find_by(auth_subject_uid: auth.uid) || find_by(email: auth.info.email.downcase)

    if admin
      admin.update!(auth_subject_uid: auth.uid, auth_provider: auth.provider)
    end

    admin
  end
end
