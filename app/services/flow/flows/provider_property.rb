module Flow
  module Flows
    class ProviderProperty < FlowSteps
      STEPS = {
        own_homes: {
          path: ->(application) { urls.providers_legal_aid_application_means_own_home_path(application) },
          forward: ->(application) { application.own_home_no? ? :vehicles : :property_details },
          carry_on_sub_flow: ->(application) { !application.own_home_no? },
          check_answers: ->(app) { app.checking_non_passported_means? ? :check_capital_answers : :check_passported_answers },
        },
        # TODO: move to provider_capital and delete this file
        property_details: {
          path: ->(application) { urls.providers_legal_aid_application_means_property_details_path(application) },
          forward: :vehicles,
          check_answers: :restrictions,
        },
        shared_ownerships: {
          path: ->(application) { urls.providers_legal_aid_application_means_shared_ownership_path(application) },
          forward: lambda do |application|
                     if application.shared_ownership?
                       :percentage_homes
                     else
                       application.checking_answers? ? :restrictions : :vehicles
                     end
                   end,
          carry_on_sub_flow: true,
        },
        percentage_homes: {
          path: ->(application) { urls.providers_legal_aid_application_means_percentage_home_path(application) },
          forward: ->(application) { application.checking_answers? ? :restrictions : :vehicles },
          carry_on_sub_flow: true,
        },
      }.freeze
    end
  end
end
