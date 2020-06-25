module Flow
  module Flows
    class ProviderProperty < FlowSteps
      STEPS = {
        own_homes: {
          path: ->(application) { urls.providers_legal_aid_application_own_home_path(application) },
          forward: ->(application) { application.own_home_no? ? :vehicles : :property_values },
          carry_on_sub_flow: ->(application) { !application.own_home_no? },
          check_answers: ->(app) { app.checking_non_passported_means? ? :means_summaries : :check_passported_answers }
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
              application.checking_answers? ? :restrictions : :vehicles
            end
          end,
          carry_on_sub_flow: true
        },
        percentage_homes: {
          path: ->(application) { urls.providers_legal_aid_application_percentage_home_path(application) },
          forward: ->(application) { application.checking_answers? ? :restrictions : :vehicles },
          carry_on_sub_flow: true
        }
      }.freeze
    end
  end
end
