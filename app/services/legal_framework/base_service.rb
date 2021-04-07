module LegalFramework
  class BaseService
    def self.call(submission = nil)
      new(submission).call
    end

    attr_reader :submission

    def initialize(submission)
      @submission = submission
    end

    def call
      @response = query_legal_framework_api
    end

    def legal_framework_url
      File.join(host, url_path)
    end

    def request_id
      @submission.id
    end

    def legal_aid_application
      @legal_aid_application ||= @submission.legal_aid_application
    end

    private

    # override this method in the derived class if you need more/different headers
    def headers
      {
        'Content-Type' => 'application/json'
      }
    end

    def conn
      @conn ||= Faraday.new(url: host, headers: headers)
    end

    def host
      Rails.configuration.x.legal_framework_api_host
    end

    def query_legal_framework_api
      raw_response = post_request
      parsed_response = parse_json_response(raw_response.body)
      history = write_submission_history(raw_response)
      case raw_response.status
      when 200
        JSON.parse(raw_response.body, symbolize_names: true)
      else
        raise LegalFramework::SubmissionError.new(detailed_error(parsed_response, history), raw_response.status)
      end
    end

    def detailed_error(parsed_response, history)
      "Bad Request: URL: #{history.url}, details: #{parsed_response}"
    end

    def parse_json_response(response_body)
      JSON.parse(response_body, symbolize_names: true)
    rescue JSON::ParserError, TypeError
      response_body || ''
    end

    def post_request
      conn.post do |request|
        request.url url_path
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
        url: legal_framework_url,
        http_method: http_method,
        request_payload: request_body,
        http_response_status: http_status,
        error_message: message,
        error_backtrace: backtrace
      )
      raise LegalFramework::SubmissionError.new(message, http_status)
    end

    def formatted_error_message(err)
      "#{self.class} received #{err.class}: #{err.message}"
    end

    def write_submission_history(raw_response, http_method = 'POST')
      @submission.submission_histories.create!(
        url: legal_framework_url,
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
