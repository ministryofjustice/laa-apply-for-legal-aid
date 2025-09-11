class AdminUser < ApplicationRecord
  devise(
    :database_authenticatable, :trackable, :lockable,
    authentication_keys: [:username], unlock_strategy: :time
  )

  def self.from_omniauth(auth)
    admin = find_by(email: auth.info.email)

    if admin
      admin.update!(auth_subject_uid: auth.uid)
    end

    admin
  end
end
