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
            when :employed_journey_not_enabled, :provider_not_enabled_for_employed_journey, :applicant_not_employed
              :identify_types_of_incomes
            else
              raise "Unexpected hmrc status #{status.inspect}"
            end
          end,
        },
        identify_types_of_incomes: {
          path: ->(application) { urls.providers_legal_aid_application_means_identify_types_of_income_path(application) },
          forward: lambda do |application|
            application.transaction_types.credits.any? ? :cash_incomes : :student_finances
          end,
          check_answers: lambda do |application|
            if application.uploading_bank_statements?
              application.transaction_types.credits.any? ? :cash_incomes : :means_summaries
            else
              :income_summary
            end
          end,
        },
        cash_incomes: {
          path: ->(application) { urls.providers_legal_aid_application_means_cash_income_path(application) },
          forward: :student_finances,
          check_answers: :means_summaries,
        },
        student_finances: {
          path: ->(application) { urls.providers_legal_aid_application_means_student_finance_path(application) },
          forward: :identify_types_of_outgoings,
          check_answers: :means_summaries,
        },
        identify_types_of_outgoings: {
          path: ->(application) { urls.providers_legal_aid_application_identify_types_of_outgoing_path(application) },
          forward: lambda do |application|
            application.transaction_types.debits.any? ? :cash_outgoings : :applicant_bank_accounts
          end,
          check_answers: lambda do |application|
            application.transaction_types.debits.any? ? :cash_outgoings : :means_summaries # could this intend to point to outgoings_summary? need to check CYA behaviour
          end,
        },
        cash_outgoings: {
          path: ->(application) { urls.providers_legal_aid_application_means_cash_outgoing_path(application) },
          forward: :applicant_bank_accounts,
          check_answers: :means_summaries,
        },
        # this page is not mentioned in the flow but we have a required question on it and this is the only
        # place we replay the accounts back to the provider. I have added it here because it is just before we ask users
        # to organise the transactions from these accounts.
        applicant_bank_accounts: {
          path: ->(application) { urls.providers_legal_aid_application_applicant_bank_account_path(application) },
          forward: :income_summary,
          check_answers: :means_summaries,
        },
        offline_accounts: {
          path: ->(application) { urls.providers_legal_aid_application_offline_account_path(application) },
          forward: :savings_and_investments,
          check_answers: ->(application) { application.checking_non_passported_means? ? :means_summaries : :check_passported_answers },
        },
        income_summary: {
          path: ->(application) { urls.providers_legal_aid_application_income_summary_index_path(application) },
          forward: :outgoings_summary,
          check_answers: :means_summaries,
        },
        # I dont think these are needed - if so remove from flow and assciated views and controllers
        # no_income_summaries: {
        #   path: ->(application) { urls.providers_legal_aid_application_no_income_summary_path(application) },
        #   forward: ->(_, has_confirm_no_income) { has_confirm_no_income ? :outgoings_summary : :identify_types_of_incomes },
        # },
        outgoings_summary: {
          path: ->(application) { urls.providers_legal_aid_application_outgoings_summary_index_path(application) },
          forward: :has_dependants,
          check_answers: :means_summaries,
        },
        # I dont think these are needed - if so remove from flow and assciated views and controllers
        # no_outgoings_summaries: {
        #   path: ->(application) { urls.providers_legal_aid_application_no_outgoings_summary_path(application) },
        #   forward: ->(_, has_confirm_no_outgoings) { has_confirm_no_outgoings ? :has_dependants : :identify_types_of_outgoings },
        # },
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
          forward: :identify_types_of_incomes,
          check_answers: :means_summaries,
        },
        full_employment_details: {
          path: ->(application) { urls.providers_legal_aid_application_means_full_employment_details_path(application) },
          forward: :identify_types_of_incomes,
          check_answers: :means_summaries,
        },
        capital_introductions: {
          path: ->(application) { urls.providers_legal_aid_application_capital_introduction_path(application) },
          forward: :own_homes,
        },
        means_summaries: {
          path: ->(application) { urls.providers_legal_aid_application_means_summary_path(application) },
          forward: lambda do |application|
            application.uploading_bank_statements? ? :no_eligibility_assessments : :capital_income_assessment_results
          end,
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
