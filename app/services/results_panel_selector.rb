class ResultsPanelSelector
  def self.call(legal_aid_application)
    new(legal_aid_application).call
  end

  def initialize(legal_aid_application)
    @legal_aid_application = legal_aid_application
  end

  def call
    return eligible_or_non_eligible if %w[eligible not_eligible].include?(assessment_result)
    return 'shared/assessment_results/manual_check_required' if restrictions? || disregards? || extra_employment_information?

    "shared/assessment_results/#{cfe_result}#{capital_contribution}#{income_contribution}"
  end

  private

  def cfe_result
    @cfe_result ||= @legal_aid_application.cfe_result.overview
  end

  def assessment_result
    @assessment_result ||= @legal_aid_application.cfe_result.assessment_result
  end

  def capital_contribution
    return unless cfe_result == 'partially_eligible'

    '_capital' if @legal_aid_application.cfe_result.capital_contribution_required?
  end

  def income_contribution
    return unless cfe_result == 'partially_eligible'

    '_income' if @legal_aid_application.cfe_result.income_contribution_required?
  end

  def restrictions?
    @legal_aid_application.has_restrictions?
  end

  def disregards?
    @legal_aid_application.policy_disregards?
  end

  def extra_employment_information?
    @legal_aid_application.extra_employment_information?
  end

  def eligible_or_non_eligible
    return 'shared/assessment_results/manual_check_required' if extra_employment_information?

    "shared/assessment_results/#{assessment_result}"
  end
end
