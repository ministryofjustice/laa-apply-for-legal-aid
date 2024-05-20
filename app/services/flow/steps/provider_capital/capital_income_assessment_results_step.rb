module Flow
  module Steps
    module ProviderCapital
      CapitalIncomeAssessmentResultsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_capital_income_assessment_result_path(application) },
        forward: ->(application) { application.copy_case? ? :check_merits_answers : :merits_task_lists },
      )
    end
  end
end
