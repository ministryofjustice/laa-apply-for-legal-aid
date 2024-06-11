module Flow
  module Steps
    module ProviderCapital
      MeansReportsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_report_path(application) },
      )
    end
  end
end
