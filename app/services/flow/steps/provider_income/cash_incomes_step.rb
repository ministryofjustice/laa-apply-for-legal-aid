module Flow
  module Steps
    module ProviderIncome
      CashIncomesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_cash_income_path(application) },
        forward: :student_finances,
        check_answers: ->(application) { application.uploading_bank_statements? ? :check_income_answers : :income_summary },
      )
    end
  end
end
