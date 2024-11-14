class Firm < ApplicationRecord
  has_many :offices
  has_many :providers
  has_many :legal_aid_applications, through: :providers

  has_many :actor_permissions, as: :permittable
  has_many :permissions, through: :actor_permissions

  def self.search(search_term)
    if search_term
      where("name ILIKE ?", "%#{search_term}%")
    else
      all
    end
  end
end
