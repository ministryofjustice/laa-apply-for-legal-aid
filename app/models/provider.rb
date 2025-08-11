class Provider < ApplicationRecord
  encrypts :auth_subject_uid, deterministic: true

  devise :trackable

  serialize :roles, coder: YAML
  serialize :offices, coder: YAML

  belongs_to :firm, optional: true
  belongs_to :selected_office, class_name: :Office, optional: true
  has_many :legal_aid_applications
  has_and_belongs_to_many :offices

  has_many :actor_permissions, as: :permittable
  has_many :permissions, through: :actor_permissions

  delegate :name, to: :firm, prefix: true, allow_nil: true

  # Our flow can/should rely on ANY user who is on the external EntraID (and who has a certain role in the auth payload TBC)
  # NOTE: SILAS is currently returning a single office code as a string and multiple as an array of strings. This handles
  # both scenarios.
  def self.from_omniauth(auth)
    find_or_initialize_by(auth_provider: auth.provider, auth_subject_uid: auth.uid).tap do |record|
      office_codes = auth.extra.raw_info.LAA_ACCOUNTS

      record.update!(
        name: [auth.info.first_name, auth.info.last_name].join(" "),
        username: auth.extra.raw_info.USER_NAME,
        email: auth.info.email,
        office_codes: [office_codes].join(":"),
      )
    end
  rescue StandardError => e
    Rails.logger.info("#{__method__}: omniauth enountered error #{e}")
    nil
  end

  def silas_office_codes
    @silas_office_codes ||= office_codes.split(":") || []
  end

  def user_permissions
    permissions.empty? ? firm_permissions : permissions
  end

  def firm_permissions
    firm.nil? ? [] : firm.permissions
  end

  # TODO: AP-6181: will need to change this or remove/replace entirely
  def ccms_apply_role?
    return true if Rails.configuration.x.omniauth_entraid.mock_auth == "true"
    return true if auth_provider.eql?("entra_id") && auth_subject_uid.present?

    return false if roles.nil?

    roles.split(",").include?("CCMS_Apply")
  end

  def invalid_login?
    invalid_login_details.present?
  end

  def provider_details_api_error?
    invalid_login_details == "provider_details_api_error"
  end
end
