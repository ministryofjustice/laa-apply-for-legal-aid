class LegalAidApplication < ApplicationRecord
  include AASM

  SHARED_OWNERSHIP_YES_REASONS = %w[partner_or_ex_partner housing_assocation_or_landlord friend_family_member_or_other_individual].freeze
  SHARED_OWNERSHIP_NO_REASONS = %w[no_sole_owner].freeze
  SHARED_OWNERSHIP_REASONS =  SHARED_OWNERSHIP_YES_REASONS + SHARED_OWNERSHIP_NO_REASONS

  belongs_to :applicant, optional: true
  has_many :application_proceeding_types
  has_many :proceeding_types, through: :application_proceeding_types
  has_one :benefit_check_result
  has_one :other_assets_declaration
  has_one :savings_amount
  has_many :legal_aid_application_restrictions
  has_many :restrictions, through: :legal_aid_application_restrictions

  before_create :create_app_ref
  before_save :set_open_banking_consent_choice_at

  attr_reader :proceeding_type_codes
  validate :proceeding_type_codes_existence

  enum(
    own_home: {
      no: 'no'.freeze,
      mortgage: 'mortgage'.freeze,
      owned_outright: 'owned_outright'.freeze
    },
    _prefix: true
  )

  aasm column: :state do
    state :initiated, initial: true
    state :checking_answers
    state :answers_checked
    state :provider_submitted

    event :check_your_answers do
      transitions from: :initiated, to: :checking_answers
      transitions from: :answers_checked, to: :checking_answers
    end

    event :answers_checked do
      transitions from: :checking_answers, to: :answers_checked
    end

    event :provider_submit do
      transitions from: :initiated, to: :provider_submitted
      transitions from: :checking_answers, to: :provider_submitted
      transitions from: :answers_checked, to: :provider_submitted
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
    self.benefit_check_result ||= build_benefit_check_result
    benefit_check_result.update!(
      result: benefit_check_response.dig(:benefit_checker_status),
      dwp_ref: benefit_check_response.dig(:confirmation_ref)
    )
  end

  def applicant_receives_benefit?
    benefit_check_result.positive?
  end

  def benefit_check_result_needs_updating?
    return true unless benefit_check_result

    applicant_updated_after_benefit_check_result_updated?
  end

  def outstanding_mortgage?
    outstanding_mortgage_amount?
  end

  def shared_ownership?
    SHARED_OWNERSHIP_YES_REASONS.include?(shared_ownership)
  end

  def own_home?
    own_home.present? && !own_home_no?
  end

  def own_capital?
    own_home? || other_assets_declaration&.positive? || savings_amount&.positive?
  end

  private

  def applicant_updated_after_benefit_check_result_updated?
    benefit_check_result.updated_at < applicant.updated_at
  end

  def proceeding_type_codes_existence
    return unless proceeding_type_codes.present?

    errors.add(:proceeding_type_codes, :invalid) if proceeding_types.size != proceeding_type_codes.size
  end

  def create_app_ref
    self.application_ref = SecureRandom.uuid
  end

  def set_open_banking_consent_choice_at
    self.open_banking_consent_choice_at = Time.current if will_save_change_to_open_banking_consent?
  end
end
