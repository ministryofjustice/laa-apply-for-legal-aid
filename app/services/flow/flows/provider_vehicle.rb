module Flow
  module Flows
    class ProviderVehicle < FlowSteps
      STEPS = {
        vehicles: {
          path: ->(application) { urls.providers_legal_aid_application_means_vehicle_path(application) },
          forward: lambda do |application|
            if application.own_vehicle?
              :vehicle_details
            elsif application.non_passported? && !application.uploading_bank_statements?
              :applicant_bank_accounts
            else
              :offline_accounts
            end
          end,
          check_answers: ->(app) { app.checking_non_passported_means? ? :check_capital_answers : :check_passported_answers },
          carry_on_sub_flow: ->(application) { application.own_vehicle? },
        },
        vehicle_details: {
          path: ->(application) { urls.providers_legal_aid_application_means_vehicle_details_path(application) },
          forward: lambda do |application|
            if application.non_passported? && !application.uploading_bank_statements?
              :applicant_bank_accounts
            else
              :offline_accounts
            end
          end,
          check_answers: ->(app) { app.checking_non_passported_means? ? :check_capital_answers : :check_passported_answers },
        },
      }.freeze
    end
  end
end
