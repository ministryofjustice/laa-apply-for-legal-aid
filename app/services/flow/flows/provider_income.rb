module Flow
  module Flows
    class ProviderIncome < FlowSteps
      STEPS = {
        client_completed_means: Steps::ProviderIncome::ClientCompletedMeansStep,
        employment_incomes: Steps::ProviderIncome::EmploymentIncomesStep,
        unexpected_employment_incomes: Steps::ProviderIncome::UnexpectedEmploymentIncomesStep,
        full_employment_details: Steps::ProviderIncome::FullEmploymentDetailsStep,
        identify_types_of_incomes: Steps::ProviderIncome::IdentifyTypesOfIncomeStep,
        income_summary: {
          path: ->(application) { urls.providers_legal_aid_application_income_summary_index_path(application) },
          forward: lambda do |application|
            if application.outgoing_types?
              :outgoings_summary
            elsif application.applicant.has_partner_with_no_contrary_interest?
              :partner_about_financial_means
            else
              :has_dependants
            end
          end,
          check_answers: :check_income_answers,
        },
        incoming_transactions: Steps::ProviderIncome::IncomingTransactionsStep,
        regular_incomes: Steps::ProviderIncome::RegularIncomesStep,
        cash_incomes: {
          path: ->(application) { urls.providers_legal_aid_application_means_cash_income_path(application) },
          forward: :student_finances,
          check_answers: ->(application) { application.uploading_bank_statements? ? :check_income_answers : :income_summary },
        },
        student_finances: {
          path: ->(application) { urls.providers_legal_aid_application_means_student_finance_path(application) },
          forward: lambda do |application|
            application.uploading_bank_statements? ? :regular_outgoings : :identify_types_of_outgoings
          end,
          check_answers: :check_income_answers,
        },
        identify_types_of_outgoings: {
          path: ->(application) { urls.providers_legal_aid_application_means_identify_types_of_outgoing_path(application) },
          forward: lambda do |application|
            if application.outgoing_types?
              :cash_outgoings
            elsif application.income_types? && !application.uploading_bank_statements?
              :income_summary
            elsif application.applicant.has_partner_with_no_contrary_interest?
              :partner_about_financial_means
            else
              :has_dependants
            end
          end,
          check_answers: lambda do |application|
            return :cash_outgoings if application.outgoing_types?

            application.uploading_bank_statements? ? :check_income_answers : :outgoings_summary
          end,
        },
        outgoings_summary: {
          path: ->(application) { urls.providers_legal_aid_application_outgoings_summary_index_path(application) },
          forward: lambda do |application|
            if application.applicant.has_partner_with_no_contrary_interest?
              :partner_about_financial_means
            else
              :has_dependants
            end
          end,
          check_answers: :check_income_answers,
        },
        outgoing_transactions: {
          path: ->(application, params) { urls.providers_legal_aid_application_outgoing_transactions_path(application, params.slice(:transaction_type)) },
          forward: :outgoings_summary,
        },
        regular_outgoings: {
          path: ->(application) { urls.providers_legal_aid_application_means_regular_outgoings_path(application) },
          forward: lambda do |application|
            if application.applicant_outgoing_types?
              :cash_outgoings
            elsif application.applicant.has_partner_with_no_contrary_interest?
              :partner_about_financial_means
            else
              :has_dependants
            end
          end,
          check_answers: ->(application) { application.applicant_outgoing_types? ? :cash_outgoings : :check_income_answers },
        },
        cash_outgoings: {
          path: ->(application) { urls.providers_legal_aid_application_means_cash_outgoing_path(application) },
          forward: lambda do |application|
            unless application.uploading_bank_statements?
              if application.income_types?
                return :income_summary
              elsif application.outgoing_types?
                return :outgoings_summary
              end
            end
            if application.applicant.has_partner_with_no_contrary_interest?
              :partner_about_financial_means
            elsif application.uploading_bank_statements? && application.housing_payments_for?("Applicant")
              :housing_benefits
            else
              :has_dependants
            end
          end,
          check_answers: lambda do |application|
            if application.uploading_bank_statements?
              application.housing_payments_for?("Applicant") ? :housing_benefits : :check_income_answers
            else
              :outgoings_summary
            end
          end,
        },
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
