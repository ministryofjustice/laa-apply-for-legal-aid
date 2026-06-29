module Flow
  module Steps
    module ProviderCapital
      CheckCapitalAnswersStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_check_capital_answers_path(application) },
        forward: :capital_income_assessment_results,
      )
    end
  end
end
