class Firm < ApplicationRecord
  has_many :offices
  has_many :providers
  has_many :legal_aid_applications, through: :providers

  after_create do
    ActiveSupport::Notifications.instrument 'dashboard.firm_created'
  end
end
