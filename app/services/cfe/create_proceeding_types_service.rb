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

    def proceeding_type_details
      @submission.legal_aid_application.proceedings.map { |rec| { ccms_code: rec.ccms_code, client_involvement_type: rec.client_involvement_type_ccms_code } }
    end

    def process_response
      @submission.applicant_created!
      true
    end

    def applicant
      legal_aid_application.applicant
    end
  end
end
