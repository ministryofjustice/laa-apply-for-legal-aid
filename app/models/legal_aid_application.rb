# TODO: Think about how we refactor this class to make it smaller
class LegalAidApplication < ApplicationRecord # rubocop:disable Metrics/ClassLength
  include TranslatableModelAttribute
  include LegalAidApplicationStateMachine # States are defined here

  SHARED_OWNERSHIP_YES_REASONS = %w[partner_or_ex_partner housing_assocation_or_landlord friend_family_member_or_other_individual].freeze
  SHARED_OWNERSHIP_NO_REASONS = %w[no_sole_owner].freeze
  SHARED_OWNERSHIP_REASONS =  SHARED_OWNERSHIP_YES_REASONS + SHARED_OWNERSHIP_NO_REASONS
  SECURE_ID_DAYS_TO_EXPIRE = 7
  WORKING_DAYS_TO_COMPLETE_SUBSTANTIVE_APPLICATION = 20

  belongs_to :applicant, optional: true
  belongs_to :provider, optional: false
  belongs_to :office, optional: true
  has_many :application_proceeding_types, dependent: :destroy
  has_many :proceeding_types, through: :application_proceeding_types
  has_one :benefit_check_result, dependent: :destroy
  has_one :other_assets_declaration, dependent: :destroy
  has_one :savings_amount, dependent: :destroy
  has_one :merits_assessment, dependent: :destroy
  has_one :statement_of_case, dependent: :destroy
  has_one :respondent, dependent: :destroy
  has_one :latest_incident, -> { order(occurred_on: :desc) }, class_name: :Incident, dependent: :destroy
  has_many :legal_aid_application_transaction_types, dependent: :destroy
  has_many :transaction_types, through: :legal_aid_application_transaction_types
  has_many :dependants, dependent: :destroy
  has_one :ccms_submission, -> { order(created_at: :desc) }, class_name: 'CCMS::Submission', dependent: :destroy
  has_one :vehicle, dependent: :destroy
  has_many :application_scope_limitations, dependent: :destroy
  has_many :scope_limitations, through: :application_scope_limitations
  has_one_attached :merits_report
  has_one_attached :means_report

  before_create :create_app_ref
  before_save :set_open_banking_consent_choice_at

  attr_reader :proceeding_type_codes
  validate :proceeding_type_codes_existence
  validates :provider, presence: true

  delegate :full_name, to: :applicant, prefix: true, allow_nil: true
  delegate :substantive_scope_limitation, :delegated_functions_scope_limitation, to: :application_scope_limitations
  delegate :case_ccms_reference, to: :ccms_submission, allow_nil: true

  scope :latest, -> { order(created_at: :desc) }

  enum(
    own_home: {
      no: 'no'.freeze,
      mortgage: 'mortgage'.freeze,
      owned_outright: 'owned_outright'.freeze
    },
    _prefix: true
  )

  # convenience method to return the lead proceeding type.  For now, that is the ONLY
  # proceeding type until such time as we have multiple proceeding types per applications,
  # at which time this method shuld be changed to determine which is the lead one and return that.
  #
  def lead_proceeding_type
    proceeding_types.first
  end

  def calculation_date
    LegalAidApplications::CalculationDateService.call(self)
  end

  def bank_transactions
    return applicant.bank_transactions if Setting.mock_true_layer_data?

    set_transaction_period
    from = transaction_period_start_on.beginning_of_day
    to = transaction_period_finish_on.end_of_day
    applicant.bank_transactions.where(happened_at: from..to)
  end

  def generate_secure_id
    SecureData.create_and_store!(
      legal_aid_application: { id: id },
      expired_at: (Time.current + SECURE_ID_DAYS_TO_EXPIRE.days).end_of_day,
      # So each secure data payload is unique
      token: SecureRandom.hex
    )
  end

  def set_transaction_period
    return if transaction_period_start_on? && transaction_period_finish_on?

    date_to = (used_delegated_functions? ? used_delegated_functions_on : Date.current)
    date_from = date_to - 3.months

    update!(
      transaction_period_start_on: date_from,
      transaction_period_finish_on: date_to
    )
  end

  def proceeding_type_codes=(codes)
    @proceeding_type_codes = codes
    self.proceeding_types = ProceedingType.where(code: codes)
  end

  def add_benefit_check_result
    benefit_check_response = BenefitCheckService.call(self)
    return false unless benefit_check_response

    self.benefit_check_result ||= build_benefit_check_result
    benefit_check_result.update!(
      result: benefit_check_response.dig(:benefit_checker_status),
      dwp_ref: benefit_check_response.dig(:confirmation_ref)
    )
  end

  def applicant_receives_benefit?
    benefit_check_result&.positive? || false
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
    own_home? || other_assets? || savings_amount?
  end

  def savings_amount?
    savings_amount.present? && savings_amount.positive?
  end

  def other_assets?
    other_assets_declaration.present? && other_assets_declaration.positive?
  end

  # Refactored into its own method because there may be multiple conditions in the future
  # which make it read only.
  def read_only?
    checking_citizen_answers? || provider_submitted?
  end

  def checking_answers?
    checking_client_details_answers? ||
      checking_citizen_answers? ||
      checking_passported_answers? ||
      checking_merits_answers? ||
      provider_checking_citizens_means_answers?
  end

  def opponents
    [Opponent.dummy_opponent]
  end

  def wage_slips
    [] # TODO: CCMS placeholder
  end

  def opponent_other_parties
    [Opponent.dummy_opponent]
  end

  def add_default_substantive_scope_limitation!
    ApplicationScopeLimitation.create!(
      legal_aid_application: self,
      scope_limitation: lead_proceeding_type.default_substantive_scope_limitation,
      substantive: true
    )
  end

  def add_default_delegated_functions_scope_limitation!
    ApplicationScopeLimitation.create!(
      legal_aid_application: self,
      scope_limitation: lead_proceeding_type.default_delegated_functions_scope_limitation,
      substantive: false
    )
  end

  def reset_delegated_functions
    self.used_delegated_functions = false
    self.used_delegated_functions_on = nil
  end

  def reset_proceeding_types!
    proceeding_types.clear
    scope_limitations.clear
    reset_delegated_functions
  end

  def default_cost_limitation
    used_delegated_functions? ? default_delegated_functions_cost_limitation : default_substantive_cost_limitation
  end

  def default_substantive_cost_limitation
    lead_proceeding_type.default_cost_limitation_substantive
  end

  def default_delegated_functions_cost_limitation
    lead_proceeding_type.default_cost_limitation_delegated_functions
  end

  def ccms_submission
    create_ccms_submission! unless super
    super
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
    self.application_ref = ReferenceNumberCreator.call unless application_ref.present?
  end

  def set_open_banking_consent_choice_at
    self.open_banking_consent_choice_at = Time.current if will_save_change_to_open_banking_consent?
  end
end
