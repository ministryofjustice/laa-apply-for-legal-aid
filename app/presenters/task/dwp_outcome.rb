module Task
  class DWPOutcome < Base
    def path
      Flow::Steps::ProviderDWPOverride::ReceivedBenefitConfirmationsStep.path.call(application)
    end
  end
end
