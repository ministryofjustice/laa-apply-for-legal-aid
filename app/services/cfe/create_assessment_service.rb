module CFE
  class CreateAssessmentService < BaseService
    def cfe_url_path
      '/assessments'
    end

    def request_body
      request_hash.to_json
    end

    private

    def request_hash
      {
        client_reference_id: legal_aid_application.application_ref,
        submission_date: legal_aid_application.calculation_date.strftime('%Y-%m-%d')
      }.merge(options)
    end

    def options
      {
        proceeding_types: {
          ccms_codes: legal_aid_application.proceeding_types.map(&:ccms_code)
        }
      }
    end

    def process_response
      @submission.assessment_id = @response['assessment_id']
      @submission.assessment_created!
      true
    end
  end
end
