module Flow
  module Flows
    module ProviderCapital
      STEPS = {
        own_homes: {
          path: ->(application, urls) { urls.providers_legal_aid_application_own_home_path(application) },
          forward: ->(application) { application.own_home_no? ? :savings_and_investments : :property_values },
          carry_on_sub_flow: ->(application) { !application.own_home_no? },
          check_answers: :check_passported_answers
        },
        property_values: {
          path: ->(application, urls) { urls.providers_legal_aid_application_property_value_path(application) },
          forward: ->(application) { application.own_home_mortgage? ? :outstanding_mortgages : :shared_ownerships },
          carry_on_sub_flow: true,
          check_answers: :check_passported_answers
        },
        outstanding_mortgages: {
          path: ->(application, urls) { urls.providers_legal_aid_application_outstanding_mortgage_path(application) },
          forward: :shared_ownerships,
          carry_on_sub_flow: true,
          check_answers: :check_passported_answers
        },
        shared_ownerships: {
          path: ->(application, urls) { urls.providers_legal_aid_application_shared_ownership_path(application) },
          forward: ->(application) { application.shared_ownership? ? :percentage_homes : :savings_and_investments },
          carry_on_sub_flow: ->(application) { application.shared_ownership? },
          check_answers: :check_passported_answers
        },
        percentage_homes: {
          path: ->(application, urls) { urls.providers_legal_aid_application_percentage_home_path(application) },
          forward: :savings_and_investments,
          check_answers: :check_passported_answers
        },
        savings_and_investments: {
          path: ->(application, urls) { urls.providers_legal_aid_application_savings_and_investment_path(application) },
          forward: :other_assets,
          check_answers: :check_passported_answers
        },
        other_assets: {
          path: ->(application, urls) { urls.providers_legal_aid_application_other_assets_path(application) },
          forward: ->(application) { application.own_capital? ? :restrictions : :check_passported_answers },
          check_answers: :check_passported_answers
        },
        restrictions: {
          path: ->(application, urls) { urls.providers_legal_aid_application_restrictions_path(application) },
          forward: :check_passported_answers,
          check_answers: :check_passported_answers
        },
        check_passported_answers: {
          path: ->(application, urls) { urls.providers_legal_aid_application_check_passported_answers_path(application) },
          forward: :client_received_legal_helps
        }
      }.freeze
    end
  end
end
