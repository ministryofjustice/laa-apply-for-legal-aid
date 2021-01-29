module CFE
  class CreateAssessmentService < BaseService
    def cfe_url_path
      '/assessments'
    end

    def request_body
      {
        client_reference_id: legal_aid_application.application_ref,
        submission_date: legal_aid_application.calculation_date,
        matter_proceeding_type: 'domestic_abuse'
      }.to_json
    end

    private

    def process_response
      @submission.assessment_id = @response['assessment_id']
      @submission.assessment_created!
      true
    end
  end
end
