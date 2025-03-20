module CFECivil
  module Components
    class Vehicles < BaseDataBlock
      def self.call(legal_aid_application, owner_type = :client)
        new(legal_aid_application, owner_type).call
      end

      def initialize(legal_aid_application, owner_type = :client)
        super
      end

      def call
        {
          vehicles: vehicles_request_body,
        }.to_json
      end

    private

      def vehicles
        legal_aid_application.vehicles.where(owner: owner_type)
      end

      def vehicles_request_body
        return [] unless vehicles.any?

        vehicles.map do |vehicle|
          {
            value: vehicle.estimated_value.to_f,
            loan_amount_outstanding: vehicle.payment_remaining.to_f,
            date_of_purchase: vehicle.cfe_civil_purchase_date&.strftime("%Y-%m-%d"),
            in_regular_use: vehicle.used_regularly,
          }
        end
      end
    end
  end
end
