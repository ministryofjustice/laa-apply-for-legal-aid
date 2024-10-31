module Flow
  module Steps
    module ProviderIncome
      IdentifyTypesOfIncomeStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_identify_types_of_income_path(application) },
        forward: lambda do |application|
          application.income_types? ? :cash_incomes : :student_finances
        end,
        check_answers: lambda do |application|
          application.income_types? ? :cash_incomes : :check_income_answers
        end,
      )
    end
  end
end
