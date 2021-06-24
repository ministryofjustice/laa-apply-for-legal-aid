class ResultsPanelSelector
  CFE_TRANSLATION = {
    eligible: :e,
    not_eligible: :x,
    capital_contribution_required: :ccr,
    income_contribution_required: :icr,
    capital_and_income_contribution_required: :cicr,
    partially_eligible: :pe,
    manual_check_required: :mcr
  }.freeze

  DECISION_TREE = {
    # ELIGIBLE
    e_no_restrictions_no_disregards: :eligible,
    e_no_restrictions_with_disregards: :eligible,
    e_with_restrictions_no_disregards: :eligible,
    e_with_restrictions_with_disregards: :eligible,

    # NOT ELIGIBLE
    x_no_restrictions_no_disregards: :not_eligible,
    x_no_restrictions_with_disregards: :not_eligible,
    x_with_restrictions_no_disregards: :not_eligible,
    x_with_restrictions_with_disregards: :not_eligible,

    # CAPITAL CONTRIBUTION REQUIRED
    ccr_no_restrictions_no_disregards: :capital_contribution_required,
    ccr_no_restrictions_with_disregards: :manual_check_disregards,
    ccr_with_restrictions_no_disregards: :manual_check_required,
    ccr_with_restrictions_with_disregards: :manual_check_disregards_restrictions,

    # INCOME CONTRIBUTION REQUIRED
    icr_no_restrictions_no_disregards: :income_contribution_required,
    icr_no_restrictions_with_disregards: :manual_check_disregards,
    icr_with_restrictions_no_disregards: :income_contribution_required,
    icr_with_restrictions_with_disregards: :manual_check_disregards_restrictions,

    # CAPITAL AND INCOME CONTRIBUTION REQUIRED
    cicr_no_restrictions_no_disregards: :capital_and_income_contribution_required,
    cicr_no_restrictions_with_disregards: :manual_check_disregards,
    cicr_with_restrictions_no_disregards: :capital_and_income_contribution_required,
    cicr_with_restrictions_with_disregards: :manual_check_disregards_restrictions,

    # PARTIALLY ELIGIBLE
    pe_with_capital_contribution_no_income_contribution_no_restrictions_no_disregards: :partially_eligible_capital,
    pe_no_capital_contribution_with_income_contribution_no_restrictions_no_disregards: :partially_eligible_income,
    pe_with_capital_contribution_with_income_contribution_no_restrictions_no_disregards: :partially_eligible_capital_income,

    pe_with_capital_contribution_no_income_contribution_no_restrictions_with_disregards: :manual_check_disregards,
    pe_no_capital_contribution_with_income_contribution_no_restrictions_with_disregards: :manual_check_disregards,
    pe_with_capital_contribution_with_income_contribution_no_restrictions_with_disregards: :manual_check_disregards,

    pe_with_capital_contribution_no_income_contribution_with_restrictions_no_disregards: :manual_check_required,
    pe_no_capital_contribution_with_income_contribution_with_restrictions_no_disregards: :manual_check_required,
    pe_with_capital_contribution_with_income_contribution_with_restrictions_no_disregards: :manual_check_required,

    pe_with_capital_contribution_no_income_contribution_with_restrictions_with_disregards: :manual_check_disregards_restrictions,
    pe_no_capital_contribution_with_income_contribution_with_restrictions_with_disregards: :manual_check_disregards_restrictions,
    pe_with_capital_contribution_with_income_contribution_income_with_restrictions_with_disregards: :manual_check_disregards_restrictions,

    # MANUAL CHECK REQUIRE
    mcr_no_restrictions_no_disregards: :manual_check_required,
    mcr_no_restrictions_with_disregards: :manual_check_disregards,
    mcr_with_restrictions_no_disregards: :manual_check_required,
    mcr_with_restrictions_with_disregards: :manual_check_disregards_restrictions
  }.freeze

  def self.call(legal_aid_application)
    new(legal_aid_application).call
  end

  def initialize(legal_aid_application)
    @legal_aid_application = legal_aid_application
  end

  def call
    key = "#{translate_overview}#{capital_contribution}#{income_contribution}_#{restrictions}_#{disregards}".to_sym
    partial = DECISION_TREE.fetch(key)
    "shared/assessment_results/#{partial}"
  end

  private

  def cfe_result
    @cfe_result ||= @legal_aid_application.cfe_result
  end

  def capital_contribution
    return unless cfe_result.overview == 'partially_eligible'

    cfe_result.capital_contribution_required? ? '_with_capital_contribution' : '_no_capital_contribution'
  end

  def income_contribution
    return unless cfe_result.overview == 'partially_eligible'

    cfe_result.income_contribution_required? ? '_with_income_contribution' : '_no_income_contribution'
  end

  def restrictions
    @legal_aid_application.has_restrictions? ? 'with_restrictions' : 'no_restrictions'
  end

  def disregards
    @legal_aid_application.policy_disregards? ? 'with_disregards' : 'no_disregards'
  end

  def translate_overview
    key = cfe_result.overview.to_sym
    CFE_TRANSLATION.fetch(key)
  end
end
