module Flow
  module Steps
    module ProviderIncome
      CheckIncomeAnswersStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_check_income_answers_path(application) },
        forward: :capital_introductions,
      )
    end
  end
end
