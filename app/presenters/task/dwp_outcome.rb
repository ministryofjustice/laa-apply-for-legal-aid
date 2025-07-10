module Task
  class DWPOutcome < Base
    def path
      Flow::Steps::ProviderDWPOverride::ConfirmDWPNonPassportedApplicationsStep.path.call(application)
    end
  end
end
