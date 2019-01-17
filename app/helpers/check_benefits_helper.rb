module CheckBenefitsHelper
  def result_namespace
    if @legal_aid_application.applicant_receives_benefit?
      '.positive_result'
    else
      '.negative_result'
    end
  end
end
