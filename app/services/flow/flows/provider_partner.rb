module Flow
  module Flows
    class ProviderPartner < FlowSteps
      STEPS = {
        client_has_partners: Steps::Partner::ClientHasPartnersStep,
        contrary_interests: Steps::Partner::ContraryInterestsStep,
        partner_details: Steps::Partner::DetailsStep,
        partner_about_financial_means: Steps::Partner::AboutFinancialMeansStep,
        partner_employed: Steps::Partner::EmployedStep,
        partner_use_ccms_employment: Steps::Partner::UseCCMSEmploymentStep,
        partner_bank_statements: Steps::Partner::BankStatementsStep,
        partner_receives_state_benefits: Steps::Partner::ReceivesStateBenefitsStep,
        partner_state_benefits: Steps::Partner::StateBenefitsStep,
        partner_add_other_state_benefits: Steps::Partner::AddOtherStateBenefitsStep,
        partner_remove_state_benefits: Steps::Partner::RemoveStateBenefitsStep,
        partner_regular_incomes: Steps::Partner::RegularIncomesStep,
        partner_cash_incomes: Steps::Partner::CashIncomesStep,
        partner_student_finances: Steps::Partner::StudentFinancesStep,
        partner_regular_outgoings: Steps::Partner::RegularOutgoingsStep,
        partner_cash_outgoings: Steps::Partner::CashOutgoingsStep,
        partner_full_employment_details: Steps::Partner::FullEmploymentDetailsStep,
        partner_employment_incomes: Steps::Partner::EmploymentIncomesStep,
        partner_unexpected_employment_incomes: Steps::Partner::UnexpectedEmploymentIncomeStep,
      }.freeze
    end
  end
end
