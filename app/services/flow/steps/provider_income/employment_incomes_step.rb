module Flow
  module Steps
    module ProviderIncome
      EmploymentIncomesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_employment_income_path(application) },
        forward: lambda do |application|
          if application.uploading_bank_statements?
            :receives_state_benefits
          else
            :identify_types_of_incomes
          end
        end,
        check_answers: :check_income_answers,
      )
    end
  end
end
