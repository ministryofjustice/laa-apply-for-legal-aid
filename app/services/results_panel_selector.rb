class ResultsPanelSelector
  DECISION_TREE = {
    eligible_no_restrictions_no_disregards: :eligible,
    eligible_no_restrictions_with_disregards: :eligible,
    eligible_with_restrictions_no_disregards: :eligible,
    eligible_with_restrictions_with_disregards: :eligible,

    not_eligible_no_restrictions_no_disregards: :not_eligible,
    not_eligible_no_restrictions_with_disregards: :not_eligible,
    not_eligible_with_restrictions_no_disregards: :not_eligible,
    not_eligible_with_restrictions_with_disregards: :not_eligible,

    capital_contribution_required_no_restrictions_no_disregards: :capital_contribution_required,
    capital_contribution_required_no_restrictions_with_disregards: :manual_check_disregards,
    capital_contribution_required_with_restrictions_no_disregards: :manual_check_required,
    capital_contribution_required_with_restrictions_with_disregards: :manual_check_disregards_restrictions,

    income_contribution_required_no_restrictions_no_disregards: :income_contribution_required,
    income_contribution_required_no_restrictions_with_disregards: :manual_check_disregards,
    income_contribution_required_with_restrictions_no_disregards: :income_contribution_required,
    income_contribution_required_with_restrictions_with_disregards: :manual_check_disregards_restrictions,

    capital_and_income_contribution_required_no_restrictions_no_disregards: :capital_and_income_contribution_required,
    capital_and_income_contribution_required_no_restrictions_with_disregards: :manual_check_disregards,
    capital_and_income_contribution_required_with_restrictions_no_disregards: :capital_and_income_contribution_required,
    capital_and_income_contribution_required_with_restrictions_with_disregards: :manual_check_disregards_restrictions,

    manual_check_required_no_restrictions_no_disregards: :manual_check_required,
    manual_check_required_no_restrictions_with_disregards: :manual_check_disregards,
    manual_check_required_with_restrictions_no_disregards: :manual_check_required,
    manual_check_required_with_restrictions_with_disregards: :manual_check_disregards_restrictions
  }.freeze

  def self.call(legal_aid_application)
    new(legal_aid_application).call
  end

  def initialize(legal_aid_application)
    @legal_aid_application = legal_aid_application
  end

  def call
    key = "#{cfe_result.overview}_#{restrictions}_#{disregards}".to_sym
    partial = DECISION_TREE.fetch(key)
    "shared/assessment_results/#{partial}"
  end

  private

  def cfe_result
    @cfe_result ||= @legal_aid_application.cfe_result
  end

  def restrictions
    @legal_aid_application.has_restrictions? ? 'with_restrictions' : 'no_restrictions'
  end

  def disregards
    @legal_aid_application.policy_disregards? ? 'with_disregards' : 'no_disregards'
  end
end
