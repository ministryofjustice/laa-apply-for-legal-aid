module Flow
  module Steps
    module ProviderCapital
      CapitalIncomeAssessmentResultsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_capital_income_assessment_result_path(application) },
        forward: lambda do |application|
          if application.copy_case?
            application.evidence_is_required? ? :uploaded_evidence_collections : :check_merits_answers
          else
            :merits_task_lists
          end
        end,
      )
    end
  end
end
