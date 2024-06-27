module Flow
  module Steps
    module ProviderStart
      SubstantiveApplicationsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_substantive_application_path(application) },
        forward: lambda do |application|
          return :delegated_confirmation unless application.substantive_application?

          if application.applicant_receives_benefit?
            :capital_introductions
          else
            :open_banking_consents
          end
        end,
      )
    end
  end
end
