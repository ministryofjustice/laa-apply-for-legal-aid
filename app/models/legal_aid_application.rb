class LegalAidApplication < ApplicationRecord
  include AASM

  belongs_to :applicant, optional: true
  has_many :application_proceeding_types
  has_many :proceeding_types, through: :application_proceeding_types
  has_one :benefit_check_result

  before_create :create_app_ref
  before_save :set_consented_date

  attr_reader :proceeding_type_codes, :open_banking_consent, :consented_at
  validate :proceeding_type_codes_existence

  aasm column: :state do
    state :initiated, initial: true
    state :checking_answers
    state :provider_submitted

    event :check_your_answers do
      transitions from: :initiated, to: :checking_answers
    end

    event :provider_submit do
      transitions from: :initiated, to: :provider_submitted
      transitions from: :checking_answers, to: :provider_submitted
    end

    event :reset do
      transitions from: :checking_answers, to: :initiated
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

  def set_consented_date
    self.consented_at = Time.current if will_save_change_to_open_banking_consent?
  end
end
