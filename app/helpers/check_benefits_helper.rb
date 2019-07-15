module CheckBenefitsHelper
  def result_namespace
    @legal_aid_application.applicant_receives_benefit? ? '.positive_result' : '.negative_result'
  end
end
