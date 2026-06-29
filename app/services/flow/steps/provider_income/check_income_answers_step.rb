module Flow
  module Steps
    module ProviderIncome
      CheckIncomeAnswersStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_check_income_answers_path(application) },
        forward: lambda do |application|
          application.return_to_review_and_print? ? :capital_income_assessment_results : :capital_introductions
        end,
      )
    end
  end
end
