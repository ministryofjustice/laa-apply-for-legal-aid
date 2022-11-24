class LegalAidApplication < ApplicationRecord
  include TranslatableModelAttribute
  include Discard::Model
  include DelegatedFunctions

  ProceedingStruct = Struct.new(:name, :meaning, :proceeding)

  SHARED_OWNERSHIP_YES_REASONS = %w[partner_or_ex_partner housing_assocation_or_landlord friend_family_member_or_other_individual].freeze
  SHARED_OWNERSHIP_NO_REASONS = %w[no_sole_owner].freeze
  SHARED_OWNERSHIP_REASONS =  SHARED_OWNERSHIP_YES_REASONS + SHARED_OWNERSHIP_NO_REASONS
  SECURE_ID_DAYS_TO_EXPIRE = 7
  WORKING_DAYS_TO_COMPLETE_SUBSTANTIVE_APPLICATION = 20
  MAX_SUBSTANTIVE_COST_LIMIT = 25_000
  CCMS_SUBMITTED_STATES = %w[generating_reports submitting_assessment assessment_submitted].freeze
  POLICY_DISREGARDS_START_DATE = Rails.configuration.x.policy_disregards_start_date

  belongs_to :applicant, optional: true, dependent: :destroy
  belongs_to :provider, optional: false
  belongs_to :office, optional: true
  has_many :proceedings, dependent: :destroy
  has_many :chances_of_success, through: :proceedings
  has_many :attachments, dependent: :destroy
  has_one :benefit_check_result, dependent: :destroy
  has_one :other_assets_declaration, dependent: :destroy
  has_one :savings_amount, dependent: :destroy
  has_one :statement_of_case, class_name: "ApplicationMeritsTask::StatementOfCase", dependent: :destroy
  has_one :gateway_evidence, dependent: :destroy
  has_one :uploaded_evidence_collection, dependent: :destroy
  has_one :opponent, class_name: "ApplicationMeritsTask::Opponent", dependent: :destroy
  has_one :latest_incident, -> { order(occurred_on: :desc) }, class_name: "ApplicationMeritsTask::Incident", inverse_of: :legal_aid_application, dependent: :destroy
  has_one :allegation, class_name: "ApplicationMeritsTask::Allegation", dependent: :destroy
  has_one :undertaking, class_name: "ApplicationMeritsTask::Undertaking", dependent: :destroy
  has_one :urgency, class_name: "ApplicationMeritsTask::Urgency", dependent: :destroy
  has_many :attempts_to_settles, class_name: "ProceedingMeritsTask::AttemptsToSettle", through: :proceedings
  has_many :legal_aid_application_transaction_types, dependent: :destroy
  has_many :transaction_types, through: :legal_aid_application_transaction_types
  has_many :cash_transactions, dependent: :destroy
  has_many :irregular_incomes, dependent: :destroy
  has_many :dependants, dependent: :destroy
  has_one :ccms_submission, -> { order(created_at: :desc) }, class_name: "CCMS::Submission", inverse_of: :legal_aid_application, dependent: :destroy
  has_one :vehicle, dependent: :destroy
  has_one :policy_disregards, dependent: :destroy
  has_one :dwp_override, dependent: :destroy
  has_one :bank_transaction_report, -> { where(attachment_type: "bank_transaction_report") }, class_name: "Attachment", inverse_of: :legal_aid_application, dependent: :destroy
  has_many :legal_framework_submissions, -> { order(created_at: :asc) }, class_name: "LegalFramework::Submission", inverse_of: :legal_aid_application, dependent: :destroy
  has_one :legal_framework_merits_task_list, class_name: "LegalFramework::MeritsTaskList", inverse_of: :legal_aid_application, dependent: :destroy
  has_one :merits_report, -> { where(attachment_type: "merits_report") }, class_name: "Attachment", inverse_of: :legal_aid_application, dependent: :destroy
  has_one :means_report, -> { where(attachment_type: "means_report") }, class_name: "Attachment", inverse_of: :legal_aid_application, dependent: :destroy
  has_many :cfe_submissions, -> { order(created_at: :asc) }, class_name: "CFE::Submission", inverse_of: :legal_aid_application, dependent: :destroy
  has_one :most_recent_cfe_submission, -> { order(created_at: :desc) }, class_name: "CFE::Submission", inverse_of: :legal_aid_application, dependent: :destroy
  has_many :scheduled_mailings, dependent: :destroy
  has_one :state_machine, class_name: "BaseStateMachine", dependent: :destroy
  has_many :involved_children, class_name: "ApplicationMeritsTask::InvolvedChild", dependent: :destroy
  has_many :hmrc_responses, class_name: "HMRC::Response", dependent: :destroy, inverse_of: :legal_aid_application
  has_many :employments, dependent: :destroy
  has_many :regular_transactions, dependent: :destroy
  has_one :matter_opposition, -> { order(created_at: :desc) }, class_name: "ApplicationMeritsTask::MatterOpposition", inverse_of: :legal_aid_application, dependent: :destroy

  before_save :set_open_banking_consent_choice_at
  before_create :create_app_ref
  after_create do
    ActiveSupport::Notifications.instrument "dashboard.application_created", id:, state:
  end

  after_save do
    ActiveSupport::Notifications.instrument "dashboard.declined_open_banking" if saved_change_to_open_banking_consent?
    ActiveSupport::Notifications.instrument("dashboard.provider_updated", provider_id: provider.id) if proc { |laa| laa.state }.eql?(:assessment_submitted)
  end

  validate :validate_document_categories

  delegate :bank_transactions, to: :applicant, allow_nil: true
  delegate :full_name, to: :applicant, prefix: true, allow_nil: true
  delegate :case_ccms_reference, to: :ccms_submission, allow_nil: true
  delegate :applicant_enter_means!,
           :await_applicant!,
           :check_applicant_details!,
           :check_citizen_answers!,
           :check_merits_answers!,
           :check_non_passported_means!,
           :check_passported_answers!,
           :complete_bank_transaction_analysis!,
           :complete_passported_means!,
           :enter_applicant_details!,
           :provider_confirm_applicant_eligibility!,
           :provider_assess_means!,
           :provider_enter_means!,
           :provider_enter_merits!,
           :provider_used_delegated_functions!,
           :reset!,
           :reset_from_use_ccms!,
           :reset_to_applicant_entering_means!,
           :submitted_assessment!,
           :use_ccms!,
           :applicant_details_checked?,
           :applicant_entering_means?,
           :assessment_submitted?,
           :awaiting_applicant?,
           :checking_applicant_details?,
           :checking_citizen_answers?,
           :checking_merits_answers?,
           :checking_non_passported_means?,
           :checking_passported_answers?,
           :entering_applicant_details?,
           :generating_reports?,
           :provider_assessing_means?,
           :provider_checking_or_checked_citizens_means_answers?,
           :provider_entering_means?,
           :provider_entering_merits?,
           :submitting_assessment?,
           :use_ccms?,
           :summary_state,
           :ccms_reason,
           to: :state_machine_proxy

  scope :latest, -> { order(created_at: :desc) }
  scope :search, lambda { |term|
    attributes = [
      "application_ref",
      "concat(applicants.first_name, applicants.last_name)",
      "ccms_submissions.case_ccms_reference",
    ]
    clean_term = term.to_s.downcase.gsub(/[^0-9a-z\\s]/i, "")
    queries = attributes.map do |attribute|
      left_joins(:applicant, :ccms_submission).where("regexp_replace(lower(#{attribute}),'[^[:alnum:]]', '', 'g') like ?", "%#{clean_term}%")
    end
    applications = queries.first
    queries[1..].each { |query| applications = applications.or(query) }
    applications
  }

  scope :submitted_applications, -> { joins(:state_machine).where(state_machine_proxies: { aasm_state: CCMS_SUBMITTED_STATES }).order(created_at: :desc) }

  enum(
    own_home: {
      no: "no".freeze,
      mortgage: "mortgage".freeze,
      owned_outright: "owned_outright".freeze,
    },
    _prefix: true,
  )

  def lead_proceeding
    proceedings.find_by(lead_proceeding: true)
  end

  def find_or_set_lead_proceeding
    lead_proc = lead_proceeding
    if lead_proc.nil?
      lead_proc = proceedings.detect { |p| p.ccms_code =~ /^DA/ }
      lead_proc.update! lead_proceeding: true
    end
    lead_proc
  end

  def proceedings_by_name
    # returns an array of ProceedingStruct containing:
    # - name of the proceeding type
    # - meaning of the proceeding type
    # - the Proceeding
    #
    # in the order they were added to the LegalAidApplication
    #
    proceedings.in_order_of_addition.map do |proceeding|
      ProceedingStruct.new(proceeding.name, proceeding.meaning, proceeding)
    end
  end

  def section_8_proceedings?
    proceedings.any? { |proceeding| proceeding.ccms_matter_code.eql?("KSEC8") }
  end

  def evidence_is_required?
    RequiredDocumentCategoryAnalyser.call(self)
    required_document_categories.any?
  end

  def cfe_result
    most_recent_cfe_submission&.result
  end

  def calculation_date
    LegalAidApplications::CalculationDateService.call(self)
  end

  def year_to_calculation_date
    [calculation_date - 1.year + 1.day, calculation_date]
  end

  def capture_policy_disregards?
    (calculation_date || Time.zone.today) >= POLICY_DISREGARDS_START_DATE
  end

  def transactions_total_by_category(category_id)
    bank_trx_total = transactions_total_by_type(:bank, category_id).abs
    cash_trx_total = transactions_total_by_type(:cash, category_id).abs
    cash_trx_total + bank_trx_total
  end

  def applicant_employed?
    applicant&.employed?
  end

  def applicant_self_employed?
    applicant&.self_employed?
  end

  def applicant_armed_forces?
    applicant&.armed_forces?
  end

  def employment_journey_ineligible?
    applicant&.armed_forces? || applicant_self_employed?
  end

  def applicant_not_employed?
    !applicant_employed? && !applicant_self_employed? && !applicant_armed_forces?
  end

  def pre_dwp_check?
    BaseStateMachine::PRE_DWP_STATES.include? state.to_sym
  end

  def income_types?
    transaction_types.credits.without_housing_benefits.any?
  end

  def outgoing_types?
    transaction_types.debits.any?
  end

  def generate_secure_id
    SecureData.create_and_store!(
      legal_aid_application: { id: },
      expired_at: (Time.current + SECURE_ID_DAYS_TO_EXPIRE.days).end_of_day,
      # So each secure data payload is unique
      token: SecureRandom.hex,
    )
  end

  def set_transaction_period
    return if transaction_period_start_on? && transaction_period_finish_on?

    date_to = used_delegated_functions_on || Date.current
    date_from = date_to - 3.months

    update!(
      transaction_period_start_on: date_from,
      transaction_period_finish_on: date_to,
    )
  end

  def lowest_prospect_of_success
    min_rank = chances_of_success.any? ? chances_of_success.map(&:prospect_of_success_rank).min : 1
    ProceedingMeritsTask::ChancesOfSuccess.rank_and_prettify(min_rank)
  end

  def parent_transaction_types
    ids = transaction_types.map(&:parent_or_self).map(&:id)
    TransactionType.where(id: ids)
  end

  # type is either :credit or :debit
  def uncategorised_transactions?(type)
    bank_trx = bank_transactions_by_type(type)
    cash_trx = cash_transactions_by_type(type)
    parent_transaction_types.__send__("#{type}s").each do |transaction_type|
      uncategorised_transactions_errors(transaction_type) unless any_transactions_selected?(transaction_type, bank_trx, cash_trx)
    end
    errors.present?
  end

  def add_benefit_check_result
    benefit_check_response = BenefitCheckService.call(self)
    return false unless benefit_check_response

    self.benefit_check_result ||= build_benefit_check_result
    benefit_check_result.update!(
      result: benefit_check_response[:benefit_checker_status],
      dwp_ref: benefit_check_response[:confirmation_ref],
    )
  end

  def applicant_receives_benefit?
    return true if dwp_override&.has_evidence_of_benefit?

    benefit_check_result&.positive? || false
  end

  alias_method :passported?, :applicant_receives_benefit?

  def non_passported?
    !passported?
  end

  def non_means_tested?
    !!state_machine.is_a?(NonMeansTestedStateMachine)
  end

  def benefit_check_result_needs_updating?
    return true unless benefit_check_result

    applicant_updated_after_benefit_check_result_updated?
  end

  def employment_evidence_required?
    extra_employment_information_details.present? || full_employment_details.present?
  end

  def employment_payments
    employments.map(&:employment_payments).flatten
  end

  def eligible_employment_payments
    employment_payments.select { |p| p.date >= transaction_period_start_on }
  end

  def outstanding_mortgage?
    outstanding_mortgage_amount?
  end

  def shared_ownership?
    SHARED_OWNERSHIP_YES_REASONS.include?(shared_ownership)
  end

  def shared_ownership=(new_val)
    self[:shared_ownership] = new_val
    self[:percentage_home] = 100.0 if new_val == "no_sole_owner"
  end

  def own_home?
    own_home.present? && !own_home_no?
  end

  def own_capital?
    own_home? || other_assets? || savings_amount?
  end

  def savings_amount?
    (savings_amount.present? && savings_amount&.values?)
  end

  def offline_savings?
    savings_amount&.offline_savings_accounts.present?
  end

  def offline_savings_value
    savings_amount.offline_savings_accounts
  end

  def online_savings_accounts_balance
    return nil if applicant.bank_accounts.savings.empty?

    applicant.bank_accounts.savings.sum(&:latest_balance)
  end

  def online_current_accounts_balance
    return nil if applicant.bank_accounts.current.empty?

    applicant.bank_accounts.current.sum(&:latest_balance)
  end

  def other_assets?
    other_assets_declaration.present? && other_assets_declaration.positive?
  end

  # Refactored into its own method because there may be multiple conditions in the future
  # which make it read only.
  def read_only?
    checking_citizen_answers? || with_applicant?
  end

  def with_applicant?
    applicant_entering_means? || awaiting_applicant?
  end

  def submitted_to_ccms?
    generating_reports? ||
      submitting_assessment? ||
      assessment_submitted?
  end

  def checking_answers?
    checking_applicant_details? ||
      checking_passported_answers? ||
      checking_merits_answers? ||
      checking_citizen_answers? ||
      checking_non_passported_means?
  end

  def receives_student_finance?
    student_finance?
  end

  def value_of_student_finance
    receives_student_finance? ? irregular_incomes.student_finance.order("created_at").last.amount : nil
  end

  def default_cost_limitation
    default_substantive_cost_limitation
  end

  def substantive_cost_overridable?
    substantive_cost_limitation.present? && default_substantive_cost_limitation < MAX_SUBSTANTIVE_COST_LIMIT
  end

  def substantive_cost_limitation
    if substantive_cost_override
      substantive_cost_requested
    else
      default_substantive_cost_limitation
    end
  end

  def default_substantive_cost_limitation
    proceedings.map(&:substantive_cost_limitation).max
  end

  def default_delegated_functions_cost_limitation
    lead_proceeding.delegated_functions_cost_limitation
  end

  def find_or_create_ccms_submission
    create_ccms_submission! unless ccms_submission
    ccms_submission
  end

  def ccms_submission_date
    association(:ccms_submission).load_target&.created_at
  end

  def state
    state_machine_proxy.aasm_state
  end

  def state_machine_proxy
    if state_machine.nil?
      save!
      create_state_machine(type: "PassportedStateMachine")
    end
    state_machine
  end

  def change_state_machine_type(state_machine_type)
    save!
    state_machine.update!(type: state_machine_type)
    reload
  end

  def applicant_details_checked!
    state_machine_proxy.applicant_details_checked!(self)
  end

  def generate_reports!
    state_machine_proxy.generate_reports!(self)
  end

  def generated_reports!
    state_machine_proxy.generated_reports!(self)
  end

  def restart_submission!
    state_machine_proxy.restart_submission!(self)
  end

  def statement_of_case_uploaded?
    attachments.statement_of_case.any?
  end

  def complete_non_passported_means!
    state_machine_proxy.complete_non_passported_means!(self)
  end

  def merits_complete!
    update!(merits_submitted_at: Time.current) unless merits_submitted_at?
    ActiveSupport::Notifications.instrument "dashboard.application_submitted"
  end

  def summary_state
    return :submitted if merits_submitted_at

    :in_progress
  end

  def policy_disregards?
    policy_disregards&.any? ? true : false
  end

  def transactions_total_by_type(transaction_type, category_id)
    __send__("#{transaction_type}_transactions").amounts.fetch(category_id, 0)
  end

  def hmrc_employment_income?
    employments.any?
  end

  def has_multiple_employments?
    employments.length > 1
  end

  def uploaded_evidence_by_category
    return if uploaded_evidence_collection.nil?

    out = uploaded_evidence_collection.original_attachments.group_by(&:attachment_type)
    out.transform_values { |attachment| attachment.map(&:original_filename) }
  end

  def manually_entered_employment_information?
    extra_employment_information? || full_employment_details.present?
  end

  def hmrc_response_use_case_one
    hmrc_responses.detect { |response| response.use_case == "one" }
  end

  def uploading_bank_statements?
    return false unless provider.bank_statement_upload_permissions?

    !client_open_banking_consent? || attachments.bank_statement_evidence.exists?
  end

  def has_transaction_type?(transaction_type)
    legal_aid_application_transaction_types.map(&:transaction_type_id).include?(transaction_type.id)
  end

  def using_enhanced_bank_upload?
    Setting.enhanced_bank_upload? && uploading_bank_statements?
  end

  def housing_payments?
    transaction_types.for_outgoing_type?(:rent_or_mortgage)
  end

  def housing_benefit_regular_transaction_applicable?
    using_enhanced_bank_upload? && housing_payments?
  end

private

  def client_open_banking_consent?
    return true if provider_received_citizen_consent.nil?

    provider_received_citizen_consent?
  end

  def bank_transactions_by_type(type)
    bank_transactions.__send__(type).order(happened_at: :desc).by_parent_transaction_type
  end

  def cash_transactions_by_type(type)
    cash_transactions.__send__("#{type}s").order(transaction_date: :desc).by_parent_transaction_type
  end

  def any_transactions_selected?(transaction_type, bank_trx, cash_trx)
    bank_trx[transaction_type].present? || cash_trx[transaction_type].present?
  end

  def applicant_updated_after_benefit_check_result_updated?
    benefit_check_result.updated_at < applicant.updated_at
  end

  def uncategorised_transactions_errors(transaction_type)
    add_uncategorised_transaction_error(transaction_type)
    transaction_type.children.each { |child| add_uncategorised_transaction_error(child) }
  end

  def add_uncategorised_transaction_error(transaction_type)
    return if transaction_type.disregarded_benefit?

    errors.add(transaction_type.name, I18n.t("activemodel.errors.models.legal_aid_application.attributes.uncategorised_bank_transactions.message"))
  end

  def create_app_ref
    self.application_ref = ReferenceNumberCreator.call if application_ref.blank?
  end

  def set_open_banking_consent_choice_at
    self.open_banking_consent_choice_at = Time.current if will_save_change_to_open_banking_consent?
  end

  def validate_document_categories
    required_document_categories.each do |category|
      errors.add(:required_document_categories, "must be valid document categories") unless DocumentCategory.displayable_document_category_names.include?(category)
    end
  end
end
