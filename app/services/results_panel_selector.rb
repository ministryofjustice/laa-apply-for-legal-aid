class ResultsPanelSelector
  def self.call(legal_aid_application)
    new(legal_aid_application).call
  end

  def initialize(legal_aid_application)
    @legal_aid_application = legal_aid_application
  end

  attr_reader :legal_aid_application

  delegate :has_restrictions?,
           :policy_disregards?,
           :capital_disregards?,
           :manually_entered_employment_information?,
           to: :legal_aid_application

  def call
    return eligible_or_non_eligible if %w[eligible ineligible].include?(assessment_result)
    return "shared/assessment_results/manual_check_required" if has_restrictions? || disregards? || manually_entered_employment_information?

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
    return unless cfe_result == "partially_eligible"

    "_capital" if @legal_aid_application.cfe_result.capital_contribution_required?
  end

  def income_contribution
    return unless cfe_result == "partially_eligible"

    "_income" if @legal_aid_application.cfe_result.income_contribution_required?
  end

  def disregards?
    policy_disregards? || capital_disregards?
  end

  def eligible_or_non_eligible
    return "shared/assessment_results/manual_check_required" if manually_entered_employment_information?

    "shared/assessment_results/#{assessment_result}"
  end
end
