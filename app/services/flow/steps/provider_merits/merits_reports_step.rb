module Flow
  module Steps
    module ProviderMerits
      MeritsReportsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_merits_report_path(application) },
      )
    end
  end
end
