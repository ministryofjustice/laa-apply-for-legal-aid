module Flow
  module Flows
    class ProviderIncome
      STEPS = {
        client_completed_means: Steps::ProviderIncome::ClientCompletedMeansStep,
        employed_but_no_hmrc_data_interrupts: Steps::ProviderIncome::EmployedButNoHMRCDataInterruptsStep,
        hmrc_unavailable_interrupts: Steps::ProviderIncome::HMRCUnavailableInterruptsStep,
        multiple_employments_interrupts: Steps::ProviderIncome::MultipleEmploymentsInterruptsStep,
        no_nino_interrupts: Steps::ProviderIncome::NoNinoInterruptsStep,
        single_employment_interrupts: Steps::ProviderIncome::SingleEmploymentInterruptsStep,
        unemployed_but_hmrc_found_data_interrupts: Steps::ProviderIncome::UnemployedButHMRCFoundDataInterruptsStep,
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
        housing_benefits: Steps::ProviderIncome::HousingBenefitsStep,
        check_income_answers: Steps::ProviderIncome::CheckIncomeAnswersStep,
      }.freeze
    end
  end
end
