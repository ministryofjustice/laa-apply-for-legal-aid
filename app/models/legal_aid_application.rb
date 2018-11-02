class LegalAidApplication < ApplicationRecord
  belongs_to :applicant, optional: true
  has_many :application_proceeding_types
  has_many :proceeding_types, through: :application_proceeding_types
  has_one :benefit_check_result

  before_create :create_app_ref

  attr_reader :proceeding_type_codes

  validate :proceeding_type_codes_existence

  def proceeding_type_codes=(codes)
    @proceeding_type_codes = codes
    self.proceeding_types = ProceedingType.where(code: codes)
  end

  def add_benefit_check_result
    benefit_check_response = BenefitCheckService.new(self).check_benefits
    create_benefit_check_result!(
      result: benefit_check_response.dig(:benefit_checker_status),
      dwp_ref: benefit_check_response.dig(:confirmation_ref)
    )
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
