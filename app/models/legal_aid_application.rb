class LegalAidApplication < ApplicationRecord
  belongs_to :applicant, optional: true
  has_many :application_proceeding_types
  has_many :proceeding_types, through: :application_proceeding_types
  has_one :benefit_check_result

  before_create :create_app_ref

  attr_reader :proceeding_type_codes

  validate :proceeding_type_codes_existence

  state_machine initial: :initiated do
    event :provider_submit do
      transition initiated: :provider_submitted
    end
  end

  def self.find_by_secure_id!(secure_id)
    secure_data = SecureData.for(secure_id)
    find_by! secure_data[:legal_aid_application]
  end

  def generate_secure_id
    SecureData.create_and_store!(
      legal_aid_application: { id: id },
      # So each secure data payload is unique
      token: SecureRandom.hex
    )
  end

  def proceeding_type_codes=(codes)
    @proceeding_type_codes = codes
    self.proceeding_types = ProceedingType.where(code: codes)
  end

  def add_benefit_check_result
    benefit_check_response = BenefitCheckService.new(self).call
    create_benefit_check_result!(
      result: benefit_check_response.dig(:benefit_checker_status),
      dwp_ref: benefit_check_response.dig(:confirmation_ref)
    )
  end

  def applicant_receives_benefit?
    benefit_check_result.positive?
  end

  private

  def proceeding_type_codes_existence
    return unless proceeding_type_codes.present?
    errors.add(:proceeding_type_codes, :invalid) if proceeding_types.size != proceeding_type_codes.size
  end

  def create_app_ref
    self.application_ref = SecureRandom.uuid
  end
end
