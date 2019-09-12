module CFE
  class CreateAssessmentService < BaseConnector
    def self.call(assessment)
      new(assessment).call
    end

    def initialize(assessment)
      @assessment = assessment
      @conn = Faraday.new(url: CFE_URL)
    end

    def call
      response = post_request
      process_response(response)
    end

    private

    def legal_aid_application
      @legal_aid_application ||= @assessment.legal_aid_application
    end

    def post_request
      begin
        raw_response = @conn.post do |request|
          request.url '/assessments'
          request.headers['Content-Type'] = 'application/json'
          request.body = request_body
        end
        JSON.parse(raw_response.body)
      rescue => err
        {
          'success' => false,
          'errors' => "#{err.class} #{err.message}"
        }
      end
    end

    def request_body
      {
        'client_reference_id': legal_aid_application.application_ref,
        'submission_date': legal_aid_application.calculation_date,
        'matter_proceeding_type': 'domestic_abuse'
      }.to_json
    end

    def process_response(response)
      response['success'] ? process_successful_response : process_error_response
    end

    def process_successful_response(response)
      @assessment.assessment_id = response['objects']['id']
      @assessment.create_appllicant!
    end
  end
end
