module CFE
  class CreateVehiclesService < BaseService
    private

    def cfe_url_path
      "/assessments/#{@submission.assessment_id}/vehicles"
    end

    def request_body
      {
        vehicles: [
          {
            value: vehicle.estimated_value,
            loan_amount_outstanding: vehicle.payment_remaining,
            date_of_purchase: vehicle.purchased_on.strftime('%Y-%m-%d'),
            in_regular_use: vehicle.used_regularly
          }
        ]
      }.to_json
    end

    def process_response
      @submission.vehicles_created!
    end

    def vehicle
      legal_aid_application.vehicle
    end
  end
end
