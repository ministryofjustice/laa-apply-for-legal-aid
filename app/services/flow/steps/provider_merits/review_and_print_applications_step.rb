module Flow
  module Steps
    module ProviderMerits
      ReviewAndPrintApplicationsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_review_and_print_application_path(application) },
        forward: :end_of_applications,
      )
    end
  end
end
