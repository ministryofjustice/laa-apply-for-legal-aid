module Flow
  module Steps
    module ProviderMerits
      EndOfApplicationsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_end_of_application_path(application) },
        forward: :submitted_applications,
      )
    end
  end
end
