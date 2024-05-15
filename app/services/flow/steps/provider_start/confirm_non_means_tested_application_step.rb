module Flow
  module Steps
    module ProviderStart
      ConfirmNonMeansTestedApplicationStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_confirm_non_means_tested_applications_path(application) },
        forward: ->(application) { application.copy_case? ? :check_merits_answers : :merits_task_lists },
      )
    end
  end
end
