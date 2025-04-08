module Task
  class CheckBenefits < Base
    def path
      if application.non_means_tested?
        Flow::Steps::ProviderStart::ConfirmNonMeansTestedApplicationStep.path.call(application)
      elsif !application.applicant&.national_insurance_number?
        Flow::Steps::ProviderStart::NoNationalInsuranceNumbersStep.path.call(application)
      else
        Flow::Steps::ProviderStart::CheckBenefitsStep.path.call(application)
      end
    end
  end
end
