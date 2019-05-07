module Flow
  module Flows
    class VehicleSteps < FlowSteps
      STEPS = {
        vehicles: {
          path: ->(application) { urls.providers_legal_aid_application_vehicle_path(application) },
          forward: ->(application) { application&.vehicle&.persisted? ? :vehicles_estimated_values : :savings_and_investments }
        },
        vehicles_estimated_values: {
          path: ->(application) { urls.providers_legal_aid_application_vehicles_estimated_value_path(application) },
          forward: ->(_application) { :vehicles_remaining_payments }
        },
        vehicles_remaining_payments: {
          path: ->(application) { urls.providers_legal_aid_application_vehicles_remaining_payment_path(application) },
          forward: ->(_application) { :vehicles_purchase_dates }
        },
        vehicles_purchase_dates: {
          path: ->(application) { urls.providers_legal_aid_application_vehicles_purchase_date_path(application) },
          forward: ->(_application) { :vehicles_regular_uses }
        },
        vehicles_regular_uses: {
          path: ->(application) { urls.providers_legal_aid_application_vehicles_regular_use_path(application) },
          forward: ->(_application) { :savings_and_investments }
        }
      }.freeze
    end
  end
end
