module CFE
  class ObtainAssessmentResultService < BaseService
    private

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
        @submission.results_obtained!
      else
        @submission.fail!
        error = CFE::SubmissionError.new('Unsuccessful HTTP response code', @response.status)
        catch_and_record_exception(error, 'GET')
      end
    end

    def request_body
      nil
    end
  end
end
