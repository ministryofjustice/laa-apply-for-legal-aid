module Flow
  module Flows
    class ProviderVehicle < FlowSteps
      STEPS = {
        vehicles: {
          path: ->(application) { urls.providers_legal_aid_application_vehicle_path(application) },
          forward: ->(application) { application.own_vehicle? ? :vehicles_estimated_values : :savings_and_investments },
          check_answers: ->(app) { app.provider_checking_citizens_means_answers? ? :means_summaries : :check_passported_answers },
          carry_on_sub_flow: ->(application) { application.own_vehicle? }
        },
        vehicles_estimated_values: {
          path: ->(application) { urls.providers_legal_aid_application_vehicles_estimated_value_path(application) },
          forward: :vehicles_remaining_payments
        },
        vehicles_remaining_payments: {
          path: ->(application) { urls.providers_legal_aid_application_vehicles_remaining_payment_path(application) },
          forward: :vehicles_purchase_dates
        },
        vehicles_purchase_dates: {
          path: ->(application) { urls.providers_legal_aid_application_vehicles_purchase_date_path(application) },
          forward: :vehicles_regular_uses
        },
        vehicles_regular_uses: {
          path: ->(application) { urls.providers_legal_aid_application_vehicles_regular_use_path(application) },
          forward: :savings_and_investments,
          check_answers: ->(app) { app.provider_checking_citizens_means_answers? ? :means_summaries : :check_passported_answers }
        }
      }.freeze
    end
  end
end
