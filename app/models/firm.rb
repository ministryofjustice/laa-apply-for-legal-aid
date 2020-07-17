class Firm < ApplicationRecord
  has_many :offices
  has_many :providers
  has_many :legal_aid_applications, through: :providers

  has_many :actor_permissions, as: :permittable
  has_many :permissions, through: :actor_permissions

  after_create do
    ActiveSupport::Notifications.instrument 'dashboard.firm_created'
  end

  def firm_permissions
    permissions.all
  end

  def self.search(search_term)
    if search_term
      where('name ILIKE ?', "%#{search_term}%")
    else
      all
    end
  end
end
