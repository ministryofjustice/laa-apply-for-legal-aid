module Flow
  module Steps
    module ProviderIncome
      UnexpectedEmploymentIncomesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_unexpected_employment_income_path(application) },
        forward: lambda do |application|
          if application.uploading_bank_statements?
            :regular_incomes
          else
            :identify_types_of_incomes
          end
        end,
        check_answers: :check_income_answers,
      )
    end
  end
end
