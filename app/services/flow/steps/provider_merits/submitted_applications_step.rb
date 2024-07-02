module Flow
  module Steps
    module ProviderMerits
      SubmittedApplicationsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_submitted_application_path(application) },
        forward: :providers_home,
      )
    end
  end
end
