class Provider < ApplicationRecord
  encrypts :auth_subject_uid, deterministic: true

  # devise :saml_authenticatable, :trackable
  devise :trackable, :omniauthable, omniauth_providers: [:entra_id]

  serialize :roles, coder: YAML
  serialize :offices, coder: YAML

  belongs_to :firm, optional: true
  belongs_to :selected_office, class_name: :Office, optional: true
  has_many :legal_aid_applications
  has_and_belongs_to_many :offices

  has_many :actor_permissions, as: :permittable
  has_many :permissions, through: :actor_permissions

  delegate :name, to: :firm, prefix: true, allow_nil: true

  # From our point of view we probably want to just create a user (*1 caviate) if not found by their email or username, otherwise update them.
  #
  # NB: The auth_subject_uid find_by, in combination with subsequent email find_by, was only used for the assurance tool to prevent anyone except
  # users we had manually added to the DB from being able to login. This does not meet our use case.
  #
  # Our flow can/should rely on ANY user who is on the external EntraID (*1 and who has a certain role in the auth payload TBC)
  #
  def self.from_omniauth(auth)
    # put a binding.irb here to read the auth values and check for a claims block?
    provider = find_by(auth_subject_uid: auth.uid)

    if provider
      # could potentially change auth_provider name since this is within our control, so update here too (e.g. azure_ad -> entra_id)
      provider.update!(last_sign_in_at: Time.current, auth_provider: auth.provider)
    else
      provider = find_by(email: auth.info.email, auth_subject_uid: nil)

      username = auth.extra.raw_info["USER_NAME"]

      if provider
        provider.update!(
          auth_subject_uid: auth.uid,
          auth_provider: auth.provider,
          # username: [auth.info.first_name, auth.info.last_name].join(" "),
          username:,
          last_sign_in_at: Time.current,
        )
      else
        # firm = Firm.find_by(ccms_id: "823") # This will need to be acquired by PDA or some other LASSIE solution

        provider = create!(
          auth_subject_uid: auth.uid,
          # username: [auth.info.first_name, auth.info.last_name].join(" "),
          username:,
          email: auth.info.email,
          last_sign_in_at: Time.current,
          auth_provider: auth.provider,
          # firm:,
          # offices: firm.offices,
        )
      end
    end

    # TODO: move to the after login service or a similar asychronous process
    provider.update_details_directly

    provider
  end

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
    firm.nil? ? [] : firm.permissions
  end

  def ccms_apply_role?
    return true if Rails.configuration.x.laa_portal.mock_saml == "true"

    return false if roles.nil?

    roles.split(",").include?("CCMS_Apply")
  end

  def invalid_login?
    invalid_login_details.present?
  end

  def newly_created_by_devise?
    firm_id.nil?
  end

  def provider_details_api_error?
    invalid_login_details == "provider_details_api_error"
  end

  def clear_invalid_login!
    update!(invalid_login_details: nil)
  end
end
