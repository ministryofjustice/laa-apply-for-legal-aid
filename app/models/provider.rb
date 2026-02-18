class Provider < ApplicationRecord
  class RawInfoNotFound < StandardError; end

  encrypts :auth_subject_uid, deterministic: true
  encrypts :silas_id, deterministic: true

  devise :trackable, :reauthable, :timeoutable

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
    raise RawInfoNotFound, "Claim enrichment missing from OAuth payload" if auth.extra.raw_info.empty?

    find_or_initialize_by(auth_provider: auth.provider, silas_id: auth.extra.raw_info.USER_NAME).tap do |record|
      office_codes = auth.extra.raw_info.LAA_ACCOUNTS

      record.update!(
        name: [auth.info.first_name, auth.info.last_name].join(" "),
        email: auth.info.email,
        office_codes: [office_codes].join(":"),
        selected_office: nil,
      )
    end
  rescue StandardError => e
    Rails.logger.info("#{__method__}: omniauth encountered error \"#{e}\"")
    nil
  end

  def silas_office_codes
    @silas_office_codes ||= office_codes.split(":") || []
  end

  def announcements
    Announcement.active.where.not(id: ProviderDismissedAnnouncement.where(provider: self).select("announcement_id"))
  end

  def user_permissions
    permissions.empty? ? firm_permissions : permissions
  end

  def firm_permissions
    firm.nil? ? [] : firm.permissions
  end
end
