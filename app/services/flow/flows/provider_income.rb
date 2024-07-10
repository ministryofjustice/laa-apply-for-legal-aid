module Flow
  module Flows
    class ProviderIncome < FlowSteps
      STEPS = {
        client_completed_means: Steps::ProviderIncome::ClientCompletedMeansStep,
        employment_incomes: Steps::ProviderIncome::EmploymentIncomesStep,
        unexpected_employment_incomes: Steps::ProviderIncome::UnexpectedEmploymentIncomesStep,
        full_employment_details: Steps::ProviderIncome::FullEmploymentDetailsStep,
        identify_types_of_incomes: Steps::ProviderIncome::IdentifyTypesOfIncomeStep,
        income_summary: Steps::ProviderIncome::IncomeSummaryStep,
        incoming_transactions: Steps::ProviderIncome::IncomingTransactionsStep,
        regular_incomes: Steps::ProviderIncome::RegularIncomesStep,
        cash_incomes: Steps::ProviderIncome::CashIncomesStep,
        student_finances: Steps::ProviderIncome::StudentFinancesStep,
        identify_types_of_outgoings: Steps::ProviderIncome::IdentifyTypesOfOutgoingsStep,
        outgoings_summary: Steps::ProviderIncome::OutgoingsSummaryStep,
        outgoing_transactions: Steps::ProviderIncome::OutgoingTransactionsStep,
        regular_outgoings: Steps::ProviderIncome::RegularOutgoingsStep,
        cash_outgoings: Steps::ProviderIncome::CashOutgoingsStep,
        housing_benefits: {
          path: ->(application) { urls.providers_legal_aid_application_means_housing_benefits_path(application) },
          forward: :has_dependants,
          check_answers: :check_income_answers,
        },
        check_income_answers: {
          path: ->(application) { urls.providers_legal_aid_application_means_check_income_answers_path(application) },
          forward: :capital_introductions,
        },
      }.freeze
    end
  end
end
