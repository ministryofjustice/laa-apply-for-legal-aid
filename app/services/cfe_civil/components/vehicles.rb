module CFECivil
  module Components
    class Vehicles < BaseDataBlock
      delegate :vehicles, to: :legal_aid_application

      def call
        vehicle_request_body.to_json
      end

    private

      def vehicle_request_body
        vehicles.any? ? vehicle_present_request : vehicle_absent_request
      end

      def vehicle_absent_request
        {
          vehicles: [],
        }
      end

      def vehicle_present_request
        {
          vehicles: vehicles.map do |vehicle|
            {
              value: vehicle.estimated_value.to_f,
              loan_amount_outstanding: vehicle.payment_remaining.to_f,
              date_of_purchase: vehicle.purchased_on&.strftime("%Y-%m-%d"),
              in_regular_use: vehicle.used_regularly,
            }
          end,
        }
      end
    end
  end
end
