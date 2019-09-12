module CFE
  class CreateApplicantService < BaseService
    private

    def cfe_url_path
      '/appli'
    end

    def request_body
      {
        "applicant": {
          "date_of_birth": "1999-09-11",
          "involvement_type": "applicant",
          "has_partner_opponent": false,
          "receives_qualifying_benefit": true
        }
      }.to_json
    end

    def process_response
      @response['success'] ? process_successful_response : process_error_response
    end

    def process_successful_response
      true
    end

    def applicant
      legal_aid_application.applicant
    end

  end
end
