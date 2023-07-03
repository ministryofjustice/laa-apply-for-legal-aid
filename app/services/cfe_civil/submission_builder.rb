module CFECivil
  class SubmissionBuilder < BaseService
    delegate :cfe_result, to: :submission
    attr_reader :legal_aid_application

    def initialize(legal_aid_application)
      super()
      @legal_aid_application = legal_aid_application
    end

    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    def request_body
      @request_body ||= components.each_with_object({}) do |service, request_data|
        request_data.merge! JSON.parse(service.new(@legal_aid_application).call)
      end
    end

    def submission
      @submission ||= CFE::Submission.new(legal_aid_application_id: @legal_aid_application.id)
    end

  private

    def components
      @components ||= ComponentList.call(@legal_aid_application)
    end

    def cfe_url_path
      "v6/assessments"
    end

    def cfe_url
      [cfe_url_host, cfe_url_path].join("/")
    end

    def post_request
      conn.post do |request|
        request.url cfe_url_path
        request.headers["Content-Type"] = "application/json"
        request.body = request_body.to_json
      end
    end

    def query_cfe_service
      raw_response = post_request
      parsed_response = parse_json_response(raw_response.body)
      history = build_submission_history(raw_response)
      history.save!
      submission.save!

      case raw_response.status
      when 200
        raw_response
      when 422
        mark_as_failed
        raise CFECivil::SubmissionError.new(detailed_error(parsed_response, history), 422)
      else
        mark_as_failed
        raise CFECivil::SubmissionError.new("Unsuccessful HTTP response code", raw_response.status)
      end
    end

    def parse_json_response(response_body)
      JSON.parse(response_body)
    rescue JSON::ParserError, TypeError
      response_body || ""
    end

    def process_response
      submission.cfe_result = @response.body
      submission.results_obtained!
      build_submission_history(@response).save!
      write_cfe_result
    end

    def mark_as_failed
      submission.fail!
    end

    def write_cfe_result
      CFE::V6::Result.create!(
        legal_aid_application_id: legal_aid_application.id,
        submission_id: submission.id,
        result: @response.body,
        type: "CFE::V6::Result",
      )
    end

    def detailed_error(parsed_response, history)
      "Unprocessable entity: URL: #{history.url}, details: #{parsed_response['errors'].first}"
    end

    def build_submission_history(raw_response, http_method = "POST")
      submission.submission_histories.build(
        url: cfe_url,
        http_method:,
        request_payload: request_body,
        http_response_status: raw_response.status,
        response_payload: raw_response.body,
        error_message: error_message_from_response(raw_response),
      )
    end

    def error_message_from_response(raw_response)
      raw_response.status == 200 ? nil : "Unexpected response: #{raw_response.status}"
    end
  end
end
