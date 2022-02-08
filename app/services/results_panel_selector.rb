class ResultsPanelSelector
  def self.call(legal_aid_application)
    new(legal_aid_application).call
  end

  def initialize(legal_aid_application)
    @legal_aid_application = legal_aid_application
  end

  def call
    rpd = ResultsPanelDecision.find_by!(cfe_result: "#{cfe_result}#{capital_contribution}#{income_contribution}",
                                        disregards: disregards,
                                        restrictions: restrictions,
                                        extra_employment_information: extra_employment_information)
    partial = rpd.decision
    "shared/assessment_results/#{partial}"
  end

  private

  def cfe_result
    @cfe_result ||= @legal_aid_application.cfe_result.overview
  end

  def capital_contribution
    return unless cfe_result == 'partially_eligible'

    '_with_capital_contribution' if @legal_aid_application.cfe_result.capital_contribution_required?
  end

  def income_contribution
    return unless cfe_result == 'partially_eligible'

    '_with_income_contribution' if @legal_aid_application.cfe_result.income_contribution_required?
  end

  def restrictions
    @legal_aid_application.has_restrictions?
  end

  def disregards
    @legal_aid_application.policy_disregards?
  end

  def extra_employment_information
    @legal_aid_application.extra_employment_information?
  end
end
