module Flow
  module Flows
    class ProviderCapital < FlowSteps
      STEPS = {
        capital_introductions: {
          path: ->(application) { urls.providers_legal_aid_application_capital_introduction_path(application) },
          forward: :own_homes
        },
        identify_types_of_incomes: {
          path: ->(application) { urls.providers_legal_aid_application_identify_types_of_income_path(application) },
          forward: :income_summary
        },
        identify_types_of_outgoings: {
          path: ->(application) { urls.providers_legal_aid_application_identify_types_of_outgoing_path(application) },
          forward: :outgoings_summary
        },
        # Property steps here (see ProviderProperty)
        # Vehicle steps here (see ProviderVehicle)
        offline_accounts: {
          path: ->(application) { urls.providers_legal_aid_application_offline_account_path(application) },
          forward: :savings_and_investments,
          carry_on_sub_flow: true,
          check_answers: ->(app) { app.provider_checking_citizens_means_answers? ? :means_summaries : :check_passported_answers }
        },
        savings_and_investments: {
          path: ->(application) { urls.providers_legal_aid_application_savings_and_investment_path(application) },
          forward: ->(application) { application.checking_answers? ? :restrictions : :other_assets },
          carry_on_sub_flow: ->(application) { application.savings_amount? },
          check_answers: ->(app) { app.provider_checking_citizens_means_answers? ? :means_summaries : :check_passported_answers }
        },
        other_assets: {
          path: ->(application) { urls.providers_legal_aid_application_other_assets_path(application) },
          forward: ->(application) do
            if application.own_capital?
              :restrictions
            else
              application.provider_assessing_means? ? :means_summaries : :check_passported_answers
            end
          end,
          carry_on_sub_flow: ->(application) { application.other_assets? },
          check_answers: ->(app) { app.provider_checking_citizens_means_answers? ? :means_summaries : :check_passported_answers }
        },
        restrictions: {
          path: ->(application) { urls.providers_legal_aid_application_restrictions_path(application) },
          forward: ->(app) { app.passported? ? :check_passported_answers : :means_summaries },
          check_answers: ->(app) { app.provider_checking_or_checked_citizens_means_answers? ? :means_summaries : :check_passported_answers }
        },
        check_passported_answers: {
          path: ->(application) { urls.providers_legal_aid_application_check_passported_answers_path(application) },
          forward: :capital_assessment_results
        },
        capital_assessment_results: {
          path: ->(application) { urls.providers_legal_aid_application_capital_assessment_result_path(application) },
          forward: :start_merits_assessments
        },
        client_completed_means: {
          path: ->(application) { urls.providers_legal_aid_application_client_completed_means_path(application) },
          forward: :income_summary
        },
        income_summary: {
          path: ->(application) { urls.providers_legal_aid_application_income_summary_index_path(application) },
          forward: :has_dependants,
          check_answers: :means_summaries
        },
        outgoings_summary: {
          path: ->(application) { urls.providers_legal_aid_application_outgoings_summary_index_path(application) },
          forward: :own_homes,
          check_answers: :means_summaries
        },
        incoming_transactions: {
          path: ->(application, params) { urls.providers_legal_aid_application_incoming_transactions_path(application, params.slice(:transaction_type)) },
          forward: :income_summary
        },
        outgoing_transactions: {
          path: ->(application, params) { urls.providers_legal_aid_application_outgoing_transactions_path(application, params.slice(:transaction_type)) },
          forward: :outgoings_summary
        },
        means_summaries: {
          path: ->(application) { urls.providers_legal_aid_application_means_summary_path(application) },
          forward: :capital_income_assessment_results
        },
        capital_income_assessment_results: {
          path: ->(application) { urls.providers_legal_aid_application_capital_income_assessment_result_path(application) },
          forward: :start_merits_assessments
        },
        means_reports: {
          path: ->(application) { urls.providers_legal_aid_application_means_report_path(application) }
        }
      }.freeze
    end
  end
end
