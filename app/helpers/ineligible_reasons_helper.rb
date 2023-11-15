module IneligibleReasonsHelper
  def ineligible_reasons(cfe_result)
    return "" unless cfe_result.assessment_result == "ineligible"

    reasons = ineligible_reasons_array(cfe_result)
    return ineligible_reason(reasons.first) if reasons.length == 1

    ineligible_reasons = ":<ul class='govuk-list govuk-list--bullet'>"
    reasons.each do |reason|
      ineligible_reasons += "<li>#{ineligible_reason(reason)}</li>"
    end
    ineligible_reasons += "</ul>"
  end

private

  def ineligible_reason(reason)
    t("shared.ineligible_reasons.#{reason}")
  end

  def ineligible_reasons_array(cfe_result)
    ineligible_reasons_array = []
    ineligible_reasons_array << "gross_income" if cfe_result.ineligible_gross_income?
    ineligible_reasons_array << "disposable_income" if cfe_result.ineligible_disposable_income?
    ineligible_reasons_array << "disposable_capital" if cfe_result.ineligible_disposable_capital?
    ineligible_reasons_array
  end
end
