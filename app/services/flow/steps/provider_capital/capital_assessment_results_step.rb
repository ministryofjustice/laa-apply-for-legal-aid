module Flow
  module Steps
    module ProviderCapital
      CapitalAssessmentResultsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_capital_assessment_result_path(application) },
        forward: ->(application) { application.copy_case? ? :check_merits_answers : :merits_task_lists },
      )
    end
  end
end
