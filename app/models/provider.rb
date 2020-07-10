class Provider < ApplicationRecord
  devise :saml_authenticatable, :trackable
  serialize :roles
  serialize :offices

  belongs_to :firm, optional: true
  belongs_to :selected_office, class_name: :Office, foreign_key: :selected_office_id, optional: true
  has_many :legal_aid_applications
  has_and_belongs_to_many :offices

  has_many :actor_permissions, as: :permittable
  has_many :permissions, through: :actor_permissions

  after_create do
    ActiveSupport::Notifications.instrument 'dashboard.provider_created'
  end

  delegate :name, to: :firm, prefix: true, allow_nil: true

  def update_details
    return update_details_directly unless firm

    ProviderDetailsCreatorWorker.perform_async(id)
  end

  def update_details_directly
    ProviderDetailsCreator.call(self)
  end

  def whitelisted_user?
    whitelisted_users&.any? { |user| user.casecmp(username).zero? }
  end

  def user_permissions
    firm_permissions = firm.nil? ? [] : firm.permissions
    permissions.empty? ? firm_permissions : permissions
  end

  def passported_permissions?
    user_permissions.map(&:role).include?('application.passported.*')
  end

  def non_passported_permissions?
    user_permissions.map(&:role).include?('application.non_passported.*')
  end

  private

  def whitelisted_users
    Rails.configuration.x.application.whitelisted_users
  end
end
