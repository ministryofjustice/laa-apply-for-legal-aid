module Flow
  module Steps
    module ProviderIncome
      StudentFinancesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_student_finance_path(application) },
        forward: lambda do |application|
          application.uploading_bank_statements? ? :regular_outgoings : :identify_types_of_outgoings
        end,
        check_answers: :check_income_answers,
      )
    end
  end
end
