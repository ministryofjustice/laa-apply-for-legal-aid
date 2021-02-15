module CFE
  class ObtainAssessmentResultService < BaseService
    HTTP_ERR_MESSAGE = 'CFE::ObtainAssessmentResultService received CFE::SubmissionError: Unsuccessful HTTP response code'.freeze

    private

    def headers
      if Setting.allow_cash_payment?
        {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json;version=3'
        }
      else
        {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json;version=2'
        }
      end
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

    def write_cfe_result
      Setting.allow_cash_payment? ? result_v3 : result_v2
    end

    def result_v2
      CFE::V2::Result.create!(
        legal_aid_application_id: legal_aid_application.id,
        submission_id: @submission.id,
        result: @response.body,
        type: 'CFE::V2::Result'
      )
    end

    def result_v3
      CFE::V3::Result.create!(
        legal_aid_application_id: legal_aid_application.id,
        submission_id: @submission.id,
        result: @response.body,
        type: 'CFE::V3::Result'
      )
    end
  end
end
