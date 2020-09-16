class Firm < ApplicationRecord
  has_many :offices
  has_many :providers
  has_many :legal_aid_applications, through: :providers

  has_many :actor_permissions, as: :permittable
  has_many :permissions, through: :actor_permissions

  before_create do
    self.permission_ids = [passported_permission_id]
  end

  after_create do
    ActiveSupport::Notifications.instrument 'dashboard.firm_created'
  end

  def self.search(search_term)
    if search_term
      where('name ILIKE ?', "%#{search_term}%")
    else
      all
    end
  end

  def passported_permission_id
    Permission.find_by(role: 'application.passported.*')&.id
  end
end
