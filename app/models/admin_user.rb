class AdminUser < ApplicationRecord
  validates :uid, presence: true, uniqueness: true

  devise(
    :database_authenticatable, :trackable, :lockable,
    authentication_keys: [:username], unlock_strategy: :time
  )
end
