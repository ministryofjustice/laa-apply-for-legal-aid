module Flow
  module Steps
    module ProviderStart
      ApplicantEmployedStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_applicant_employed_index_path(application) },
        forward: lambda do |application|
          next_step = application.used_delegated_functions? ? :substantive_applications : :open_banking_consents

          application.employment_journey_ineligible? ? :use_ccms_employment : next_step
        end,
      )
    end
  end
end
