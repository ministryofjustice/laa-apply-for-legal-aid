module Flow
  module Flows
    class CitizenVehicle < FlowSteps
      STEPS = {
        vehicles: {
          path: ->(_) { urls.citizens_vehicle_path },
          forward: ->(application) { application.own_vehicle? ? :vehicles_estimated_values : :savings_and_investments },
          check_answers: :check_answers,
          carry_on_sub_flow: ->(application) { application.own_vehicle? }
        },
        vehicles_estimated_values: {
          path: ->(_) { urls.citizens_vehicles_estimated_value_path },
          forward: :vehicles_remaining_payments
        },
        vehicles_remaining_payments: {
          path: ->(_) { urls.citizens_vehicles_remaining_payment_path },
          forward: :vehicles_purchase_dates
        },
        vehicles_purchase_dates: {
          path: ->(_) { urls.citizens_vehicles_purchase_date_path },
          forward: :vehicles_regular_uses
        },
        vehicles_regular_uses: {
          path: ->(_) { urls.citizens_vehicles_regular_use_path },
          forward: :savings_and_investments,
          check_answers: :check_answers
        }
      }.freeze
    end
  end
end
