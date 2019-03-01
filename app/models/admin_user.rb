class AdminUser < ApplicationRecord
  devise(
    :database_authenticatable, :trackable, :lockable,
    authentication_keys: [:username], unlock_strategy: :time
  )
end
