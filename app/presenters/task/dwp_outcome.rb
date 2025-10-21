module Task
  class DWPOutcome < Base
    def path
      if !application.applicant.national_insurance_number?
        Flow::Steps::ProviderStart::NoNationalInsuranceNumbersStep.path.call(application)
      elsif application.non_means_tested?
        Flow::Steps::ProviderStart::ConfirmNonMeansTestedApplicationStep.path.call(application)
      elsif application.dwp_result_confirmed == false
        if application.partner && application.applicant.shared_benefit_with_partner.nil?
          Flow::Steps::ProviderDWP::DWPPartnerOverridesStep.path.call(application)
        elsif application.dwp_override.nil?
          Flow::Steps::ProviderDWPOverride::CheckClientDetailsStep.path.call(application)
        elsif application.dwp_override&.passporting_benefit.nil?
          Flow::Steps::ProviderDWPOverride::ReceivedBenefitConfirmationsStep.path.call(application)
        else
          Flow::Steps::ProviderDWPOverride::HasEvidenceOfBenefitsStep.path.call(application)
        end
      else
        Flow::Steps::ProviderDWP::DWPResultsStep.path.call(application)
      end
    end
  end
end
