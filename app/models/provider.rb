class Provider < ApplicationRecord
  devise :saml_authenticatable, :trackable
  serialize :roles
  serialize :offices

  belongs_to :firm, optional: true
  belongs_to :selected_office, class_name: :Office, optional: true
  has_many :legal_aid_applications
  has_and_belongs_to_many :offices

  has_many :actor_permissions, as: :permittable
  has_many :permissions, through: :actor_permissions

  after_create do
    ActiveSupport::Notifications.instrument 'dashboard.provider_updated', provider_id: id
  end

  delegate :name, to: :firm, prefix: true, allow_nil: true

  def update_details
    return unless HostEnv.staging_or_production?

    # only schedule a background job to update details for staging and live
    ProviderDetailsCreatorWorker.perform_async(id)
  end

  def update_details_directly
    ProviderDetailsCreator.call(self)
  end

  def user_permissions
    permissions.empty? ? firm_permissions : permissions
  end

  def firm_permissions
    Sentry.capture_message("Provider Firm has no permissions with firm id: #{firm.id}") if firm&.permissions&.empty?
    firm.nil? ? [] : firm.permissions
  end

  def passported_permissions?
    user_permissions.map(&:role).include?('application.passported.*')
  end

  def non_passported_permissions?
    user_permissions.map(&:role).include?('application.non_passported.*')
  end

  def ccms_apply_role?
    return true if Rails.configuration.x.laa_portal.mock_saml == 'true'

    return false if roles.nil?

    roles.split(',').include?('CCMS_Apply')
  end

  def invalid_login?
    invalid_login_details.present?
  end

  def newly_created_by_devise?
    firm_id.nil?
  end

  def provider_details_api_error?
    invalid_login_details == 'provider_details_api_error'
  end

  def clear_invalid_login!
    update!(invalid_login_details: nil)
  end
end
