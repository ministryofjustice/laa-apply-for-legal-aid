module Flow
  module Steps
    module ProviderIncome
      RegularIncomesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_regular_incomes_path(application) },
        forward: lambda do |application|
          application.income_types? ? :cash_incomes : :student_finances
        end,
        check_answers: ->(application) { application.income_types? ? :cash_incomes : :check_income_answers },
      )
    end
  end
end
