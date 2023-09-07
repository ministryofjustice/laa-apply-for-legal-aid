module Flow
  module Flows
    class ProviderIncome < FlowSteps
      STEPS = {
        client_completed_means: {
          path: ->(application) { urls.providers_legal_aid_application_client_completed_means_path(application) },
          forward: lambda do |application|
            status = HMRC::StatusAnalyzer.call(application)
            case status
            when :applicant_multiple_employments, :applicant_no_hmrc_data
              :full_employment_details
            when :applicant_single_employment
              :employment_incomes
            when :applicant_unexpected_employment_data
              :unexpected_employment_incomes
            when :applicant_not_employed
              if application.uploading_bank_statements?
                :receives_state_benefits
              else
                :identify_types_of_incomes
              end
            else
              raise "Unexpected hmrc status #{status.inspect}"
            end
          end,
        },
        employment_incomes: {
          path: ->(application) { urls.providers_legal_aid_application_means_employment_income_path(application) },
          forward: lambda do |application|
            if application.uploading_bank_statements?
              :receives_state_benefits
            else
              :identify_types_of_incomes
            end
          end,
          check_answers: :check_income_answers,
        },
        unexpected_employment_incomes: {
          path: ->(application) { urls.providers_legal_aid_application_means_unexpected_employment_income_path(application) },
          forward: lambda do |application|
            if application.uploading_bank_statements?
              :regular_incomes
            else
              :identify_types_of_incomes
            end
          end,
          check_answers: :check_income_answers,
        },
        full_employment_details: {
          path: ->(application) { urls.providers_legal_aid_application_means_full_employment_details_path(application) },
          forward: lambda do |application|
            if application.uploading_bank_statements?
              :receives_state_benefits
            else
              :identify_types_of_incomes
            end
          end,
          check_answers: :check_income_answers,
        },
        identify_types_of_incomes: {
          path: ->(application) { urls.providers_legal_aid_application_means_identify_types_of_income_path(application) },
          forward: lambda do |application|
            application.income_types? ? :cash_incomes : :student_finances
          end,
          check_answers: lambda do |application|
            return :cash_incomes if application.income_types?

            application.uploading_bank_statements? ? :check_income_answers : :income_summary
          end,
        },
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
        incoming_transactions: {
          path: ->(application, params) { urls.providers_legal_aid_application_incoming_transactions_path(application, params.slice(:transaction_type)) },
          forward: :income_summary,
        },
        regular_incomes: {
          path: ->(application) { urls.providers_legal_aid_application_means_regular_incomes_path(application) },
          forward: lambda do |application|
            application.income_types? ? :cash_incomes : :student_finances
          end,
          check_answers: ->(application) { application.income_types? ? :cash_incomes : :check_income_answers },
        },
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
          check_answers: ->(application) { application.outgoing_types? ? :cash_outgoings : :check_income_answers },
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
          forward: :own_homes,
        },
      }.freeze
    end
  end
end
