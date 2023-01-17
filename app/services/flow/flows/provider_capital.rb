module Flow
  module Flows
    class ProviderCapital < FlowSteps
      STEPS = {
        client_completed_means: {
          path: ->(application) { urls.providers_legal_aid_application_client_completed_means_path(application) },
          forward: lambda do |application|
            status = HMRC::StatusAnalyzer.call(application)
            case status
            when :hmrc_multiple_employments, :no_hmrc_data
              :full_employment_details
            when :hmrc_single_employment, :unexpected_employment_data
              :employment_incomes
            when :applicant_not_employed
              if application.uploading_bank_statements?
                :regular_incomes
              else
                :identify_types_of_incomes
              end
            else
              raise "Unexpected hmrc status #{status.inspect}"
            end
          end,
        },
        identify_types_of_incomes: {
          path: ->(application) { urls.providers_legal_aid_application_means_identify_types_of_income_path(application) },
          forward: lambda do |application|
            application.income_types? ? :cash_incomes : :student_finances
          end,
          check_answers: lambda do |application|
            return :cash_incomes if application.income_types?

            application.uploading_bank_statements? ? :check_answers_incomes : :income_summary
          end,
        },
        regular_incomes: {
          path: ->(application) { urls.providers_legal_aid_application_means_regular_incomes_path(application) },
          forward: lambda do |application|
            application.income_types? ? :cash_incomes : :student_finances
          end,
          check_answers: ->(application) { application.income_types? ? :cash_incomes : :check_answers_incomes },
        },
        cash_incomes: {
          path: ->(application) { urls.providers_legal_aid_application_means_cash_income_path(application) },
          forward: :student_finances,
          check_answers: ->(application) { application.uploading_bank_statements? ? :check_answers_incomes : :income_summary },
        },
        student_finances: {
          path: ->(application) { urls.providers_legal_aid_application_means_student_finance_path(application) },
          forward: lambda do |application|
            application.uploading_bank_statements? ? :regular_outgoings : :identify_types_of_outgoings
          end,
          check_answers: :check_answers_incomes,
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

            application.uploading_bank_statements? ? :check_answers_incomes : :outgoings_summary
          end,
        },
        regular_outgoings: {
          path: ->(application) { urls.providers_legal_aid_application_means_regular_outgoings_path(application) },
          forward: lambda do |application|
            if application.housing_payments?
              :housing_benefits
            elsif application.outgoing_types?
              :cash_outgoings
            else
              :has_dependants
            end
          end,
          check_answers: lambda do |application|
            if application.housing_payments?
              :housing_benefits
            elsif application.outgoing_types?
              :cash_outgoings
            else
              :check_answers_incomes
            end
          end,
        },
        housing_benefits: {
          path: ->(application) { urls.providers_legal_aid_application_means_housing_benefits_path(application) },
          forward: :cash_outgoings,
          check_answers: :cash_outgoings,
        },
        cash_outgoings: {
          path: ->(application) { urls.providers_legal_aid_application_means_cash_outgoing_path(application) },
          forward: lambda do |application|
            return :has_dependants if application.uploading_bank_statements?

            if application.income_types?
              :income_summary
            elsif application.outgoing_types?
              :outgoings_summary
            else
              :has_dependants
            end
          end,
          check_answers: ->(application) { application.uploading_bank_statements? ? :check_answers_incomes : :outgoings_summary },
        },
        applicant_bank_accounts: {
          path: ->(application) { urls.providers_legal_aid_application_applicant_bank_account_path(application) },
          forward: :savings_and_investments,
          check_answers: :check_answers_incomes,
        },
        offline_accounts: {
          path: ->(application) { urls.providers_legal_aid_application_offline_account_path(application) },
          forward: :savings_and_investments,
          check_answers: ->(application) { application.checking_non_passported_means? ? :check_answers_incomes : :check_passported_answers },
        },
        income_summary: {
          path: ->(application) { urls.providers_legal_aid_application_income_summary_index_path(application) },
          forward: lambda do |application|
            application.outgoing_types? ? :outgoings_summary : :has_dependants
          end,
          check_answers: :check_answers_incomes,
        },
        outgoings_summary: {
          path: ->(application) { urls.providers_legal_aid_application_outgoings_summary_index_path(application) },
          forward: :has_dependants,
          check_answers: :check_answers_incomes,
        },
        incoming_transactions: {
          path: ->(application, params) { urls.providers_legal_aid_application_incoming_transactions_path(application, params.slice(:transaction_type)) },
          forward: :income_summary,
        },
        outgoing_transactions: {
          path: ->(application, params) { urls.providers_legal_aid_application_outgoing_transactions_path(application, params.slice(:transaction_type)) },
          forward: :outgoings_summary,
        },

        # Dependant steps here (see ProviderDependants)
        # Property steps here (see ProviderProperty)
        # Vehicle steps here (see ProviderVehicle)

        savings_and_investments: {
          path: ->(application) { urls.providers_legal_aid_application_means_savings_and_investment_path(application) },
          forward: lambda do |application|
            if application.own_capital? && application.checking_answers?
              :restrictions
            else
              :other_assets
            end
          end,
          carry_on_sub_flow: ->(application) { application.own_capital? },
          check_answers: ->(application) { application.checking_non_passported_means? ? :means_summaries : :check_passported_answers },
        },
        other_assets: {
          path: ->(application) { urls.providers_legal_aid_application_means_other_assets_path(application) },
          forward: lambda do |application|
            if application.own_capital?
              :restrictions
            elsif application.capture_policy_disregards?
              :policy_disregards
            else
              application.passported? ? :check_passported_answers : :means_summaries
            end
          end,
          carry_on_sub_flow: ->(application) { application.other_assets? },
          check_answers: ->(application) { application.checking_non_passported_means? ? :means_summaries : :check_passported_answers },
        },
        restrictions: {
          path: ->(application) { urls.providers_legal_aid_application_means_restrictions_path(application) },
          forward: lambda do |application|
            if application.capture_policy_disregards?
              :policy_disregards
            else
              application.passported? ? :check_passported_answers : :means_summaries
            end
          end,
          check_answers: ->(application) { application.provider_checking_or_checked_citizens_means_answers? ? :means_summaries : :check_passported_answers },
        },
        policy_disregards: {
          path: ->(application) { urls.providers_legal_aid_application_means_policy_disregards_path(application) },
          forward: ->(application) { application.passported? ? :check_passported_answers : :means_summaries },
          check_answers: ->(application) { application.provider_checking_or_checked_citizens_means_answers? ? :means_summaries : :check_passported_answers },
        },
        check_passported_answers: {
          path: ->(application) { urls.providers_legal_aid_application_check_passported_answers_path(application) },
          forward: :capital_assessment_results,
        },
        capital_assessment_results: {
          path: ->(application) { urls.providers_legal_aid_application_capital_assessment_result_path(application) },
          forward: :merits_task_lists,
        },
        employment_incomes: {
          path: ->(application) { urls.providers_legal_aid_application_means_employment_income_path(application) },
          forward: lambda do |application|
            if application.uploading_bank_statements?
              :regular_incomes
            else
              :identify_types_of_incomes
            end
          end,
          check_answers: :check_answers_incomes,
        },
        full_employment_details: {
          path: ->(application) { urls.providers_legal_aid_application_means_full_employment_details_path(application) },
          forward: lambda do |application|
            if application.uploading_bank_statements?
              :regular_incomes
            else
              :identify_types_of_incomes
            end
          end,
          check_answers: :check_answers_incomes,
        },
        capital_introductions: {
          path: ->(application) { urls.providers_legal_aid_application_capital_introduction_path(application) },
          forward: :own_homes,
        },
        check_answers_incomes: {
          path: ->(application) { urls.providers_legal_aid_application_means_check_answers_incomes_path(application) },
          forward: :own_homes,
        },
        means_summaries: {
          path: ->(application) { urls.providers_legal_aid_application_means_summary_path(application) },
          forward: :capital_income_assessment_results,
        },
        no_eligibility_assessments: {
          path: ->(application) { urls.providers_legal_aid_application_no_eligibility_assessment_path(application) },
          forward: :merits_task_lists,
        },
        capital_income_assessment_results: {
          path: ->(application) { urls.providers_legal_aid_application_capital_income_assessment_result_path(application) },
          forward: :merits_task_lists,
        },
        means_reports: {
          path: ->(application) { urls.providers_legal_aid_application_means_report_path(application) },
        },
      }.freeze
    end
  end
end
