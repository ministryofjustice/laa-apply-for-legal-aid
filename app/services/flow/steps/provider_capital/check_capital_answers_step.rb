module Flow
  module Steps
    module ProviderCapital
      CheckCapitalAnswersStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_check_capital_answers_path(application) },
        forward: lambda do |application|
          application.return_to_review_and_print ? :confirm_client_declarations : :capital_income_assessment_results
        end,
      )
    end
  end
end
