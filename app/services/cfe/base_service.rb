module CFE
  class BaseService
    def self.call(submission = nil)
      new(submission).call
    end

    attr_reader :submission

    def initialize(submission)
      @submission = submission
    end

    def call
      @response = query_cfe_service
      process_response
    end

    def cfe_url
      File.join(cfe_url_host, cfe_url_path)
    end

    private

    # override this method in the derived class if you need more/different headers
    def headers
      {
        'Content-Type' => 'application/json',
        'Accept' => "application/json;version=#{version}"
      }
    end

    def version
      Setting.allow_multiple_proceedings? ? '4' : '3'
    end

    def conn
      @conn ||= Faraday.new(url: cfe_url_host, headers: headers)
    end

    def cfe_url_host
      Rails.configuration.x.check_financial_eligibility_host
    end

    def legal_aid_application
      @legal_aid_application ||= @submission.legal_aid_application
    end

    def query_cfe_service
      raw_response = post_request
      parsed_response = parse_json_response(raw_response.body)
      history = write_submission_history(raw_response)
      case raw_response.status
      when 200
        JSON.parse(raw_response.body)
      when 422
        raise CFE::SubmissionError.new(detailed_error(parsed_response, history), 422)
      else
        raise CFE::SubmissionError.new('Unsuccessful HTTP response code', raw_response.status)
      end
    end

    def detailed_error(parsed_response, history)
      "Unprocessable entity: URL: #{history.url}, details: #{parsed_response['errors'].first}"
    end

    def parse_json_response(response_body)
      JSON.parse(response_body)
    rescue JSON::ParserError, TypeError
      response_body || ''
    end

    def post_request
      conn.post do |request|
        request.url cfe_url_path
        request.headers['Content-Type'] = 'application/json'
        request.body = request_body
      end
    rescue StandardError => e
      catch_and_record_exception(e)
    end

    def catch_and_record_exception(error, http_method = 'POST')
      raise_exception_error(
        message: formatted_error_message(error),
        backtrace: error.backtrace&.join("\n"),
        http_method: http_method,
        http_status: error.respond_to?(:http_status) ? error.http_status : nil
      )
    end

    def raise_exception_error(message:, backtrace: nil, http_method: 'POST', http_status: nil)
      @submission.submission_histories.create!(
        url: cfe_url,
        http_method: http_method,
        request_payload: request_body,
        http_response_status: http_status,
        error_message: message,
        error_backtrace: backtrace
      )
      raise CFE::SubmissionError.new(message, http_status)
    end

    def formatted_error_message(err)
      "#{self.class} received #{err.class}: #{err.message}"
    end

    def write_submission_history(raw_response, http_method = 'POST')
      @submission.submission_histories.create!(
        url: cfe_url,
        http_method: http_method,
        request_payload: request_body,
        http_response_status: raw_response.status,
        response_payload: raw_response.body,
        error_message: error_message_from_response(raw_response)
      )
    end

    def error_message_from_response(raw_response)
      raw_response.status == 200 ? nil : "Unexpected response: #{raw_response.status}"
    end
  end
end
