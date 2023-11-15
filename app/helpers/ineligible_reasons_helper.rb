module IneligibleReasonsHelper
  def ineligible_reasons(cfe_result)
    return "" unless cfe_result.assessment_result == "ineligible"

    reasons = ineligible_reasons_array(cfe_result)
    return reasons.first if reasons.length == 1

    ineligible_reasons = ":<ul class='govuk-list govuk-list--bullet'>"
    reasons.each { |reason| ineligible_reasons += "<li>#{reason}</li>" }
    ineligible_reasons += "</ul>"
  end

private

  def ineligible_reasons_array(cfe_result)
    ineligible_reasons_array = []
    ineligible_reasons_array << "gross income" if cfe_result.ineligible_gross_income?
    ineligible_reasons_array << "disposable income" if cfe_result.ineligible_disposable_income?(cfe_result)
    ineligible_reasons_array << "disposable capital" if cfe_result.ineligible_disposable_capital?(cfe_result)
    ineligible_reasons_array
  end
end
