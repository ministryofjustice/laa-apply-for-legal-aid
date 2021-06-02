module CFE
  class ObtainAssessmentResultService < BaseService
    HTTP_ERR_MESSAGE = 'CFE::ObtainAssessmentResultService received CFE::SubmissionError: Unsuccessful HTTP response code'.freeze

    private

    def headers
      {
        'Content-Type' => 'application/json',
        'Accept' => "application/json;version=#{cfe_version}"
      }
    end

    def cfe_url_path
      "/assessments/#{@submission.assessment_id}"
    end

    def query_cfe_service
      conn.get cfe_url_path
    end

    def process_response
      @submission.cfe_result = @response.body
      if @response.status == 200
        write_submission_history(@response, 'GET')
        write_cfe_result
        @submission.results_obtained!
      else
        @submission.fail! unless @submission.failed?
        raise_exception_error message: HTTP_ERR_MESSAGE, http_method: 'GET', http_status: @response.status
      end
    end

    def request_body
      nil
    end

    def cfe_version
      Setting.allow_multiple_proceedings? ? '4' : '3'
    end

    def write_cfe_result
      if Setting.allow_multiple_proceedings?
        create_version_4_result
      else
        create_version_3_result
      end
    end

    def create_version_3_result
      CFE::V3::Result.create!(
        legal_aid_application_id: legal_aid_application.id,
        submission_id: @submission.id,
        result: @response.body,
        type: 'CFE::V3::Result'
      )
    end

    def create_version_4_result
      CFE::V4::Result.create!(
        legal_aid_application_id: legal_aid_application.id,
        submission_id: @submission.id,
        result: @response.body,
        type: 'CFE::V4::Result'
      )
    end
  end
end
