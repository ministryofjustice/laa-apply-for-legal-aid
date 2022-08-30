module CFE
  class CreateProceedingTypesService < BaseService
    def cfe_url_path
      "/assessments/#{@submission.assessment_id}/proceeding_types"
    end

    def request_body
      {
        proceeding_types: proceeding_type_details,
      }.to_json
    end

  private

    def proceedings
      @submission.legal_aid_application.proceedings.order(:ccms_code)
    end

    def proceeding_type_details
      proceedings.map { |rec| { ccms_code: rec.ccms_code, client_involvement_type: rec.client_involvement_type_ccms_code } }
    end

    def process_response
      @submission.in_progress!
      true
    end
  end
end
