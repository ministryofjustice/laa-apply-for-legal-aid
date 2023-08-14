module Flow
  module Flows
    class ProviderVehicle < FlowSteps
      STEPS = {
        vehicles: {
          path: ->(application) { urls.providers_legal_aid_application_means_vehicle_path(application) },
          forward: lambda do |application|
            if application.own_vehicle?
              :vehicles_estimated_values
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
        vehicles_estimated_values: {
          path: ->(application) { urls.providers_legal_aid_application_vehicles_estimated_value_path(application) },
          forward: :vehicles_remaining_payments,
        },
        vehicles_remaining_payments: {
          path: ->(application) { urls.providers_legal_aid_application_vehicles_remaining_payment_path(application) },
          forward: :vehicles_ages,
        },
        vehicles_ages: {
          path: ->(application) { urls.providers_legal_aid_application_vehicles_age_path(application) },
          forward: :vehicles_regular_uses,
        },
        vehicles_regular_uses: {
          path: ->(application) { urls.providers_legal_aid_application_vehicles_regular_use_path(application) },
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
