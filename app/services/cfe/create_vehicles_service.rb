module CFE
  class CreateVehiclesService < BaseService
    def cfe_url_path
      "/assessments/#{@submission.assessment_id}/vehicles"
    end

    def request_body
      vehicle_request_body.to_json
    end

    private

    def vehicle_request_body
      vehicle.nil? ? vehicle_absent_request : vehicle_present_request
    end

    def vehicle_absent_request
      {
        vehicles: []
      }
    end

    def vehicle_present_request
      {
        vehicles: [
          {
            value: vehicle.estimated_value,
            loan_amount_outstanding: vehicle.payment_remaining,
            date_of_purchase: vehicle.purchased_on&.strftime('%Y-%m-%d'),
            in_regular_use: vehicle.used_regularly
          }
        ]
      }
    end

    def process_response
      @submission.vehicles_created!
    end

    def vehicle
      legal_aid_application.vehicle
    end
  end
end
