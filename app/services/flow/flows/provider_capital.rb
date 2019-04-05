module Flow
  module Flows
    class ProviderCapital < FlowSteps
      STEPS = {
        capital_introductions: {
          path: ->(application) { urls.providers_legal_aid_application_capital_introduction_path(application) },
          forward: :own_homes
        },
        identify_types_of_incomes: {
          path: ->(application) { urls.providers_legal_aid_application_identify_types_of_income_path(application) }
        },
        identify_types_of_outgoings: {
          path: ->(application) { urls.providers_legal_aid_application_identify_types_of_outgoing_path(application) }
        },
        own_homes: {
          path: ->(application) { urls.providers_legal_aid_application_own_home_path(application) },
          forward: ->(application) { application.own_home_no? ? :savings_and_investments : :property_values },
          carry_on_sub_flow: ->(application) { !application.own_home_no? },
          check_answers: ->(app) { app.provider_checking_citizens_means_answers? ? :means_summaries : :check_passported_answers }
        },
        property_values: {
          path: ->(application) { urls.providers_legal_aid_application_property_value_path(application) },
          forward: ->(application) { application.own_home_mortgage? ? :outstanding_mortgages : :shared_ownerships },
          carry_on_sub_flow: true
        },
        outstanding_mortgages: {
          path: ->(application) { urls.providers_legal_aid_application_outstanding_mortgage_path(application) },
          forward: :shared_ownerships,
          carry_on_sub_flow: true
        },
        shared_ownerships: {
          path: ->(application) { urls.providers_legal_aid_application_shared_ownership_path(application) },
          forward: ->(application) do
            if application.shared_ownership?
              :percentage_homes
            else
              application.checking_answers? ? :restrictions : :savings_and_investments
            end
          end,
          carry_on_sub_flow: true
        },
        percentage_homes: {
          path: ->(application) { urls.providers_legal_aid_application_percentage_home_path(application) },
          forward: ->(application) { application.checking_answers? ? :restrictions : :savings_and_investments },
          carry_on_sub_flow: true
        },
        savings_and_investments: {
          path: ->(application) { urls.providers_legal_aid_application_savings_and_investment_path(application) },
          forward: ->(application) { application.checking_answers? ? :restrictions : :other_assets },
          carry_on_sub_flow: ->(application) { application.savings_amount? },
          check_answers: ->(app) { app.provider_checking_citizens_means_answers? ? :means_summaries : :check_passported_answers }
        },
        other_assets: {
          path: ->(application) { urls.providers_legal_aid_application_other_assets_path(application) },
          forward: ->(application) { application.own_capital? ? :restrictions : :check_passported_answers },
          carry_on_sub_flow: ->(application) { application.other_assets? },
          check_answers: ->(app) { app.provider_checking_citizens_means_answers? ? :means_summaries : :check_passported_answers }
        },
        restrictions: {
          path: ->(application) { urls.providers_legal_aid_application_restrictions_path(application) },
          forward: :check_passported_answers,
          check_answers: ->(app) { app.provider_checking_citizens_means_answers? ? :means_summaries : :check_passported_answers }
        },
        check_passported_answers: {
          path: ->(application) { urls.providers_legal_aid_application_check_passported_answers_path(application) },
          forward: :start_merits_assessments
        },
        means_summaries: {
          path: ->(application) { urls.providers_legal_aid_application_means_summary_path(application) },
          forward: :start_merits_assessments
        }
      }.freeze
    end
  end
end
