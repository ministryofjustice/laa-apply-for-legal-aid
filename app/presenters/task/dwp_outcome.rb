module Task
  class DWPOutcome < Base
    def path
      if application.dwp_override.nil?
        Flow::Steps::ProviderDWPOverride::CheckClientDetailsStep.path.call(application)
      elsif application.dwp_override&.passporting_benefit.nil?
        Flow::Steps::ProviderDWPOverride::ReceivedBenefitsConfirmationStep.path.call(application)
      else
        Flow::Steps::ProviderDWPOverride::HasEvidenceOfBenefitsStep.path.call(application)
      end
    end
  end
end
