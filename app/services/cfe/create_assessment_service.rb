module CFE
  class CreateAssessmentService < BaseService
    private

    def cfe_url_path
      '/assessments'
    end

    def request_body
      {
        'client_reference_id': legal_aid_application.application_ref,
        'submission_date': legal_aid_application.calculation_date,
        'matter_proceeding_type': 'domestic_abuse'
      }.to_json
    end

    def process_successful_response
      @assessment.assessment_id = @response['objects'].first['id']
      true
    end
  end
end
