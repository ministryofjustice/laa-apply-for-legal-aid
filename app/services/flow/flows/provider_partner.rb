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
        partner_state_benefits: {
          path: ->(application) { urls.new_providers_legal_aid_application_partners_state_benefit_path(application) },
          forward: :partner_add_other_state_benefits,
        },
        partner_add_other_state_benefits: {
          path: ->(application) { urls.providers_legal_aid_application_partners_add_other_state_benefits_path(application) },
          forward: lambda do |_application, add_other_state_benefits|
            add_other_state_benefits ? :partner_state_benefits : :partner_regular_incomes
          end,
          check_answers: lambda do |_application, add_other_state_benefits|
            add_other_state_benefits ? :partner_state_benefits : :check_income_answers
          end,
        },
        partner_remove_state_benefits: Steps::Partner::RemoveStateBenefitsStep,
        partner_regular_incomes: {
          path: ->(application) { urls.providers_legal_aid_application_partners_regular_incomes_path(application) },
          forward: lambda do |application|
            application.partner_income_types? ? :partner_cash_incomes : :partner_student_finances
          end,
          check_answers: ->(application) { application.partner_income_types? ? :partner_cash_incomes : :check_income_answers },
        },
        partner_cash_incomes: {
          path: ->(application) { urls.providers_legal_aid_application_partners_cash_income_path(application) },
          forward: :partner_student_finances,
          check_answers: :check_income_answers,
        },
        partner_student_finances: {
          path: ->(application) { urls.providers_legal_aid_application_partners_student_finance_path(application) },
          forward: :partner_regular_outgoings,
          check_answers: :check_income_answers,
        },
        partner_regular_outgoings: Steps::Partner::RegularOutgoingsStep,
        partner_cash_outgoings: Steps::Partner::CashOutgoingsStep,
        partner_full_employment_details: Steps::Partner::FullEmploymentDetailsStep,
        partner_employment_incomes: Steps::Partner::EmploymentIncomesStep,
        partner_unexpected_employment_incomes: Steps::Partner::UnexpectedEmploymentIncomeStep,
      }.freeze
    end
  end
end
